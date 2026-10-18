import os;
import from services.llmBridge { llm_compose }
import from services.evidenceService { initial_evidence }
import from services.caseLogic { InterviewOutcome, get_lead_statuses, find_contradictions }

# The four agents: Lead Detective, Suspect Interviewer, Evidence Analyst, Devil's Advocate.
# Each one first builds a deterministic draft from verified case state. If a Gemini key is
# configured on the server, the model may rephrase the draft in the agent's voice. The model
# output is then guarded; anything suspicious falls back to the draft. Agents advise only.
# The verdict is decided by the case engine in services/caseManager.jac.

obj AdvisorReply {
    has agent: str;
    has message: str;
    has citations: list[str] = [];
    has mode: str = "rules-only";
    has next_steps: list[str] = [];
}

obj AdvisorInfo {
    has role: str;
    has name: str;
    has description: str;
}

glob BANNED_PHRASES: list[str] = ["is the culprit", "is guilty", "is the thief", "case solved", "as an ai", "language model", "i cannot assist"];
glob ALL_EVIDENCE_IDS: list[str] = ["E-01", "E-02", "E-03", "E-04"];

def:pub list_advisors() -> list[AdvisorInfo] {
    return [
        AdvisorInfo(role="lead", name="Lead Detective", description="Points to the next open lead and the gap in your case."),
        AdvisorInfo(role="interviewer", name="Suspect Interviewer", description="Voices each suspect's answers from fixed statements."),
        AdvisorInfo(role="evidence", name="Evidence Analyst", description="Explains what your secured records do and do not prove."),
        AdvisorInfo(role="advocate", name="Devil's Advocate", description="Challenges your theory with the strongest alternative.")
    ];
}

def:pub llm_available() -> bool {
    return os.environ.get("GEMINI_API_KEY", "").strip() != "";
}

def _guard_llm(candidate: str, draft: str, allowed_ids: list[str]) -> str {
    text = candidate.strip();
    if text == "" or len(text) > 700 { return draft; }
    lowered = text.lower();
    for banned in BANNED_PHRASES {
        if banned in lowered { return draft; }
    }
    for evidence_id in ALL_EVIDENCE_IDS {
        if evidence_id in text and not (evidence_id in allowed_ids) { return draft; }
    }
    return text;
}

def _polish(instructions: str, facts: str, request: str, draft: str, allowed_ids: list[str]) -> str {
    if not llm_available() { return draft; }
    try {
        candidate = llm_compose(instructions, facts, request, draft);
        return _guard_llm(candidate, draft, allowed_ids);
    } except Exception {
        return draft;
    }
}

def _mode_for(polished: str, draft: str) -> str {
    if polished != draft { return "gemini · guarded"; }
    return "rules-only";
}

def _facts_for(discovered: list[str]) -> str {
    lines: list[str] = [];
    for item in initial_evidence() {
        if item.id in discovered { lines.append(item.id + " " + item.title + ": " + item.detail); }
    }
    if len(lines) == 0 { return "No evidence has been secured yet."; }
    return " ".join(lines);
}

# 1. Suspect Interviewer. The deterministic engine chooses WHAT the suspect says.
#    The model may only change HOW it is phrased.
def:pub voice_suspect(persona: str, outcome: InterviewOutcome, question: str, allowed_ids: list[str]) -> AdvisorReply {
    instructions = "You voice " + persona + ". Rewrite the DRAFT in first person in at most 60 words. Keep every claim, name, and time exactly as written. Add no new facts. Do not say who is guilty.";
    polished = _polish(instructions, outcome.line, question, outcome.line, allowed_ids);
    return AdvisorReply(agent="Suspect Interviewer", message=polished, citations=outcome.citations, mode=_mode_for(polished, outcome.line));
}

# 2. Lead Detective.
def:pub advise_lead_detective(discovered: list[str], revealed: list[str]) -> AdvisorReply {
    findings = find_contradictions(discovered, revealed);
    found_ids = [f.id for f in findings];
    leads = get_lead_statuses(discovered, revealed, found_ids);
    open_leads = [lead for lead in leads if not lead.resolved];
    draft = "";
    steps: list[str] = [];
    if len(open_leads) == 0 {
        draft = "Every known lead is resolved. Build your theory from the secured records, then file your accusation.";
    } else {
        draft = "Next lead: " + open_leads[0].title + ". " + open_leads[0].hint;
        if len(discovered) == 0 { draft = "Visit a location to secure your first record. " + draft; }
        for lead in open_leads {
            if len(steps) < 3 { steps.append(lead.title); }
        }
    }
    instructions = "You are the Lead Detective, a calm senior investigator. Rewrite the DRAFT in at most 60 words. Keep every fact. Never say who is guilty.";
    polished = _polish(instructions, _facts_for(discovered), "What should I do next?", draft, discovered + revealed);
    return AdvisorReply(agent="Lead Detective", message=polished, citations=[], mode=_mode_for(polished, draft), next_steps=steps);
}

# 3. Evidence Analyst.
def:pub advise_evidence_analyst(discovered: list[str], revealed: list[str]) -> AdvisorReply {
    findings = find_contradictions(discovered, revealed);
    key_found = 0;
    for f in findings {
        if f.significance == "key" { key_found = key_found + 1; }
    }
    draft = "";
    citations: list[str] = [];
    if len(discovered) == 0 {
        draft = "No records are secured yet. System logs outrank recollection, so visit a location and secure what is there before weighing anyone's story.";
    } elif "E-01" in discovered and "E-03" in discovered {
        draft = "Two independent system records tie the same director credential to the 21:08 lift override and the 21:14 archive entry. The credential alone does not show who carried the case, so compare it with the route evidence and with who could hold that authority.";
        citations = ["E-01", "E-03"];
    } elif "E-02" in discovered and "E-04" in discovered {
        draft = "The lift residue and the corridor still support a transport route, but the camera image does not identify the carrier. Secure the credential records before naming a person.";
        citations = ["E-02", "E-04"];
    } else {
        draft = str(len(discovered)) + " of 4 case records secured. Treat the corridor still as unidentified and every statement as unverified until a record confirms it.";
        citations = discovered;
    }
    if key_found > 0 { draft = draft + " Key contradictions logged: " + str(key_found) + "."; }
    instructions = "You are the Evidence Analyst, a neutral forensic examiner. Rewrite the DRAFT in at most 70 words. Keep every fact. Treat statements as unverified. Never identify a culprit.";
    polished = _polish(instructions, _facts_for(discovered), "What do my records prove?", draft, discovered + revealed);
    return AdvisorReply(agent="Evidence Analyst", message=polished, citations=citations, mode=_mode_for(polished, draft));
}

# 4. Devil's Advocate.
def:pub advise_devils_advocate(theory: str, discovered: list[str], revealed: list[str]) -> AdvisorReply {
    text = theory.strip();
    if len(text) == 0 or len(text) > 1000 {
        return AdvisorReply(agent="Devil's Advocate", message="Write a theory between 1 and 1,000 characters so there is something to challenge.");
    }
    points: list[str] = [];
    if "E-01" in discovered and "E-03" in discovered {
        points.append("Does your theory explain both the 21:08 lift override and the 21:14 archive entry, which used the same credential?");
        points.append("Could someone else have used that credential? Test who else could authorize the lift.");
    } else {
        points.append("Which secured record, not a statement, supports each step of this theory?");
    }
    if "E-04" in discovered {
        points.append("The corridor still shows a lab-coated figure but cannot identify them. Do not treat it as proof of identity.");
    }
    if "ST-JUNE-MOTIVE" in revealed or "ST-ELI-MOTIVE" in revealed {
        points.append("Motive alone does not give access. Compare each motive with what that person could actually authorize.");
    }
    if "ST-JUNE-LIFT" in revealed and "ST-ELI-OTHERS" in revealed {
        points.append("June's and Eli's accounts of the 21:21 call support each other. Consider what that rules out.");
    }
    draft = "Challenges to test: " + " ".join(points);
    instructions = "You are the Devil's Advocate. Rewrite the DRAFT in at most 80 words as sharp questions that argue the strongest alternative. Keep every fact. Never confirm or deny who is guilty.";
    polished = _polish(instructions, _facts_for(discovered), text, draft, discovered + revealed);
    return AdvisorReply(agent="Devil's Advocate", message=polished, citations=discovered, mode=_mode_for(polished, draft));
}
