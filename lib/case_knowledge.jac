import from .missing_prototype_case { missing_prototype_case }

# Fixed, authored knowledge for "The Missing Prototype".
# Nothing here is random and nothing here is written by a model.
# Statements are what suspects say. Evidence records live in missing_prototype_case.
# The culprit stays in missing_prototype_canonical_solution (lib/missing_prototype_case.jac).

obj Statement {
    has id: str;
    has suspect_id: str;
    has topic: str;
    has line: str;
    has kind: str;
    has presents: list[str] = [];
}

obj Contradiction {
    has id: str;
    has title: str;
    has statement_id: str;
    has against_id: str;
    has significance: str;
    has explanation: str;
}

obj Lead {
    has id: str;
    has title: str;
    has hint: str;
    has visible_when_any: list[str] = [];
    has resolved_when_all: list[str] = [];
}

obj TimelineSeed {
    has id: str;
    has time: str;
    has text: str;
    has kind: str;
    has needs_all: list[str] = [];
}

glob TOPIC_PRIORITY: list[str] = ["lift", "access", "others", "motive", "alibi"];

glob TOPIC_KEYWORDS: dict[str, list[str]] = {
    "lift": ["lift", "elevator", "override", "manual mode", "freight", "maintenance"],
    "access": ["badge", "credential", "archive", "access", "door", "keycard", "entered", "clearance", "permission"],
    "others": ["who else", "anyone else", "someone else", "colleague", "coworker", "co-worker", "blame", "suspect"],
    "motive": ["motive", "why", "patent", "funding", "audit", "promotion", "reason", "benefit", "gain", "money", "fired", "career"],
    "alibi": ["where", "alibi", "doing", "laboratory", " lab", "desk", "tonight", "evening", "21:", "9pm", "were you"]
};

glob GENERIC_LINES: dict[str, str] = {
    "mara": "Mara studies you for a moment. 'Be specific. Ask me about where I was, the archive, the lift, or why anyone would take Helix.'",
    "eli": "Eli keeps his answer short. 'I can speak to what the system records. Ask about the archive, the lift, or my movements.'",
    "june": "June shrugs. 'I'll help where I can. Ask about the lift, the archive, my patent, or where I was.'"
};

glob STATEMENTS: list[Statement] = [
    Statement(id="ST-MARA-ALIBI", suspect_id="mara", topic="alibi", kind="alibi", line="I was in the east laboratory from nine until half past, reviewing samples. That room has no badge reader, so no record will show it, but I was there."),
    Statement(id="ST-MARA-ACCESS-1", suspect_id="mara", topic="access", kind="claim", line="My director badge opens the archive, naturally. I did not go in tonight. If a log says otherwise, the log is wrong."),
    Statement(id="ST-MARA-ACCESS-2", suspect_id="mara", topic="access", kind="revision", presents=["E-01"], line="Very well. I looked into the archive at 21:14 after a door alert I took for a false alarm. I was inside less than two minutes, the case was in its cradle, and I left. I did not mention it because I knew how it would look."),
    Statement(id="ST-MARA-LIFT-1", suspect_id="mara", topic="lift", kind="claim", line="Freight-lift overrides are routine maintenance. I don't recall requesting one tonight."),
    Statement(id="ST-MARA-LIFT-2", suspect_id="mara", topic="lift", kind="deflection", presents=["E-03"], line="The request came from the archive terminal at 21:08, on my credential, six minutes before I say I entered that room. Director logins are sometimes left open on that terminal. I did not type that request."),
    Statement(id="ST-MARA-LIFT-3", suspect_id="mara", topic="lift", kind="deflection", presents=["E-02"], line="A residue ring proves a case rode the lift. It does not prove who pressed the button. Ask whoever else could authorize that lift."),
    Statement(id="ST-MARA-MOTIVE", suspect_id="mara", topic="motive", kind="motive", line="Helix funds my division's renewal. Losing it hurts me more than anyone, so why would I make it disappear before the demonstration?"),
    Statement(id="ST-MARA-OTHERS", suspect_id="mara", topic="others", kind="redirect", line="Eli built the access system, so he knows how logs behave. June has her patent. I would ask them where they were."),

    Statement(id="ST-ELI-ALIBI", suspect_id="eli", topic="alibi", kind="alibi", line="I stayed at the security desk the whole shift. Check my console."),
    Statement(id="ST-ELI-ALIBI-2", suspect_id="eli", topic="alibi", kind="revision", presents=["E-04"], line="All right. The corridor feed flickered around 21:16 and I walked to the junction box to reseat it. I was back at the desk by 21:20. My shift notes have gaps, which is what the audit was about. I should have logged it."),
    Statement(id="ST-ELI-ACCESS", suspect_id="eli", topic="access", kind="claim", line="The system records the credential, not the person carrying the case. Both the archive entry and the lift override used the director credential. Mine can't do either."),
    Statement(id="ST-ELI-LIFT", suspect_id="eli", topic="lift", kind="claim", line="I can see lift requests on my console, but I can't authorize a manual-mode override. That takes director clearance."),
    Statement(id="ST-ELI-MOTIVE", suspect_id="eli", topic="motive", kind="motive", line="The audit faulted my documentation, not my controls. A theft on my watch would end my career, so I had every reason to stop it."),
    Statement(id="ST-ELI-OTHERS", suspect_id="eli", topic="others", kind="corroboration", line="June phoned the desk at 21:21 to ask about the lift noise. I answered from the desk on the second ring."),

    Statement(id="ST-JUNE-ALIBI", suspect_id="june", topic="alibi", kind="alibi", line="I was in the west laboratory writing a materials report. My terminal autosaved at 21:05 and again at 21:27."),
    Statement(id="ST-JUNE-LIFT", suspect_id="june", topic="lift", kind="corroboration", line="I heard the freight lift around 21:18 and assumed maintenance had called it in. I phoned the security desk at 21:21 to ask, and Eli picked up."),
    Statement(id="ST-JUNE-ACCESS", suspect_id="june", topic="access", kind="claim", line="My clearance covers the research wing, not the archive. The lift override needs a director."),
    Statement(id="ST-JUNE-ACCESS-2", suspect_id="june", topic="access", kind="claim", presents=["E-03"], line="Then it wasn't me. I have never held director credentials, and my badge can't open that terminal's override menu."),
    Statement(id="ST-JUNE-MOTIVE", suspect_id="june", topic="motive", kind="motive", line="The patent covers the casing alloy. Stealing Helix would wreck my own claim. A dispute is a reason to argue, not to steal."),
    Statement(id="ST-JUNE-OTHERS", suspect_id="june", topic="others", kind="redirect", line="Mara guards that archive personally. Eli keeps the logs. I only noticed the lift because it was loud.")
];

glob CONTRADICTIONS: list[Contradiction] = [
    Contradiction(id="C-01", title="East laboratory vs archive log", statement_id="ST-MARA-ALIBI", against_id="E-01", significance="key", explanation="Mara says she was in the east laboratory throughout, but the archive access record places her director badge inside the archive at 21:14."),
    Contradiction(id="C-02", title="'I did not go in' vs archive log", statement_id="ST-MARA-ACCESS-1", against_id="E-01", significance="key", explanation="Mara said she did not enter the archive tonight. The badge record shows she did."),
    Contradiction(id="C-03", title="'No override' vs maintenance record", statement_id="ST-MARA-LIFT-1", against_id="E-03", significance="key", explanation="Mara does not recall requesting a lift override, yet the maintenance record shows one on her credential at 21:08 from the archive terminal."),
    Contradiction(id="C-04", title="First entry at 21:14 vs 21:08 override", statement_id="ST-MARA-ACCESS-2", against_id="E-03", significance="key", explanation="Mara says she first entered the archive at 21:14, but a lift override on her credential came from the archive terminal at 21:08."),
    Contradiction(id="C-05", title="Eli's desk claim vs his own correction", statement_id="ST-ELI-ALIBI", against_id="ST-ELI-ALIBI-2", significance="minor", explanation="Eli first said he never left the desk, then admitted stepping away from 21:16 to 21:20. That is a documentation gap, not a link to the theft: he was back at the desk for June's 21:21 call and the camera still is from 21:22.")
];

glob LEADS: list[Lead] = [
    Lead(id="L-01", title="Test Mara's east-laboratory alibi", hint="Compare her stated location with the access records.", resolved_when_all=["C-01"]),
    Lead(id="L-02", title="Find out who can authorize a freight-lift override", hint="Ask each suspect about the lift and secure the maintenance record.", visible_when_any=["E-02", "E-03", "ST-JUNE-LIFT"], resolved_when_all=["E-03", "ST-ELI-LIFT", "ST-JUNE-ACCESS"]),
    Lead(id="L-03", title="Compare the two accounts of the 21:21 phone call", hint="Eli and June each describe a call to the security desk.", visible_when_any=["ST-JUNE-LIFT", "ST-ELI-OTHERS"], resolved_when_all=["ST-JUNE-LIFT", "ST-ELI-OTHERS"]),
    Lead(id="L-04", title="Identify the carrier in the corridor still", hint="The image alone names no one. Combine it with credential records.", visible_when_any=["E-04"], resolved_when_all=["E-04", "E-01", "E-03"]),
    Lead(id="L-05", title="Weigh motive against opportunity", hint="Patents and audits explain pressure, not access.", visible_when_any=["ST-MARA-MOTIVE", "ST-ELI-MOTIVE", "ST-JUNE-MOTIVE"], resolved_when_all=["ST-MARA-MOTIVE", "ST-ELI-MOTIVE", "ST-JUNE-MOTIVE"])
];

# Official public-record events with no evidence attached are shown after these ids are known.
glob OFFICIAL_EVENT_GATES: dict[str, list[str]] = {
    "T-01": ["ST-MARA-ALIBI"]
};

glob TIMELINE_SEEDS: list[TimelineSeed] = [
    TimelineSeed(id="X-01", time="21:05", text="June says her west-laboratory terminal autosaved a report.", kind="claim", needs_all=["ST-JUNE-ALIBI"]),
    TimelineSeed(id="X-02", time="21:16", text="Eli says the corridor feed flickered and he left the desk to reseat it.", kind="claim", needs_all=["ST-ELI-ALIBI-2"]),
    TimelineSeed(id="X-03", time="21:18", text="June says she heard the freight lift moving.", kind="claim", needs_all=["ST-JUNE-LIFT"]),
    TimelineSeed(id="X-04", time="21:21", text="June says she phoned the security desk. Eli says he answered at the desk. Two accounts agree.", kind="corroborated", needs_all=["ST-JUNE-LIFT", "ST-ELI-OTHERS"]),
    TimelineSeed(id="X-05", time="21:27", text="June says her terminal autosaved again.", kind="claim", needs_all=["ST-JUNE-ALIBI"])
];

# Evidence is secured at a location. Locations with no evidence still give context.
glob LOCATION_EVIDENCE: dict[str, list[str]] = {
    "archive": ["E-01"],
    "freight-lift": ["E-02", "E-03"],
    "loading-bay": ["E-04"],
    "east-lab": [],
    "security-desk": [],
    "west-lab": []
};

glob LOCATION_NOTES: dict[str, str] = {
    "archive": "The reader keeps a badge log. The door shows no damage and the alarm never tripped.",
    "freight-lift": "A service lift between the research wing and the loading corridor. Its panel keeps a maintenance log and the floor shows a faint ring of residue.",
    "loading-bay": "A controlled service exit covered by one corridor camera. The footage is grainy.",
    "east-lab": "This door has no badge reader. Nothing here confirms or denies who was inside during the incident.",
    "security-desk": "The console shows system requests and credentials, not who physically held a badge. Last month's audit flagged gaps in the shift notes.",
    "west-lab": "A working terminal and open patent drafts. Nothing here ties anyone to the archive or the lift."
};

glob PERSONAS: dict[str, str] = {
    "mara": "Mara Voss, an exacting research director who answers with controlled composure",
    "eli": "Eli Navarro, a methodical security engineer who speaks in short, precise sentences",
    "june": "Dr. June Park, a candid materials scientist who talks plainly"
};

def:pub is_valid_case_knowledge() -> bool {
    record = missing_prototype_case.public_record;
    suspect_ids = [s.id for s in record.suspects];
    evidence_ids = [e.id for e in record.evidence];
    location_ids = [l.id for l in missing_prototype_case.locations];
    statement_ids = [s.id for s in STATEMENTS];
    contradiction_ids = [c.id for c in CONTRADICTIONS];
    if len(set(statement_ids)) != len(statement_ids) { return False; }
    if len(set(contradiction_ids)) != len(contradiction_ids) { return False; }
    for st in STATEMENTS {
        if not (st.suspect_id in suspect_ids) or st.line.strip() == "" { return False; }
        for ev in st.presents {
            if not (ev in evidence_ids) { return False; }
        }
    }
    known = evidence_ids + statement_ids;
    for c in CONTRADICTIONS {
        if not (c.statement_id in statement_ids) or not (c.against_id in known) { return False; }
    }
    lead_refs = known + contradiction_ids;
    for lead in LEADS {
        refs = lead.visible_when_any + lead.resolved_when_all;
        for ref in refs {
            if not (ref in lead_refs) { return False; }
        }
    }
    for seed in TIMELINE_SEEDS {
        for ref in seed.needs_all {
            if not (ref in statement_ids) { return False; }
        }
    }
    placed: list[str] = [];
    for loc_id in LOCATION_EVIDENCE {
        if not (loc_id in location_ids) or not (loc_id in LOCATION_NOTES) { return False; }
        for ev in LOCATION_EVIDENCE[loc_id] {
            if not (ev in evidence_ids) { return False; }
            placed = placed + [ev];
        }
    }
    for ev in evidence_ids {
        if not (ev in placed) { return False; }
    }
    for loc_id in location_ids {
        if not (loc_id in LOCATION_EVIDENCE) { return False; }
    }
    for sid in suspect_ids {
        if not (sid in PERSONAS) or not (sid in GENERIC_LINES) { return False; }
    }
    return True;
}
