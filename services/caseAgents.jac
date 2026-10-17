import from lib.casezero_domain { CaseRecord, EvidenceItem, Suspect, Theory }
import from lib.missing_prototype_case { missing_prototype_case_data }

obj AgentBrief {
    has agent: str;
    has message: str;
    has citations: list[str] = [];
    has mode: str = "rules-only";
}

obj InterviewReply {
    has message: str;
    has agent: str;
    has citations: list[str] = [];
    has mode: str = "rules-only";
}

obj LeadPlan {
    has next_action: str;
    has gap: str;
    has agent: str;
    has mode: str = "rules-only";
}

# The specialist roles operate on verified case data only. Their deterministic
# tools and bounded replies remain available when no model credentials are set.
def:pub lead_detective_agent(discovered: list[str], interviewed: list[str]) -> LeadPlan {
    next_action = "Inspect the archive access log to test the director's alibi.";
    gap = "The archive entry time is not yet independently established.";
    if "E-01" in discovered and not ("E-03" in discovered) {
        next_action = "Inspect the freight-lift maintenance record.";
        gap = "The route preparation has not been verified.";
    } elif "E-01" in discovered and "E-03" in discovered and not ("mara" in interviewed) {
        next_action = "Interview Mara about the archive entry and lift override.";
        gap = "The credential holder's account needs testing.";
    } elif "E-01" in discovered and "E-03" in discovered {
        next_action = "Compare the access record with the freight route before accusing.";
        gap = "Make sure your conclusion cites secured evidence.";
    }
    return LeadPlan(next_action=next_action, gap=gap, agent="Lead Detective", mode="rules-only · verified facts");
}

def:pub interview_agent(suspect_id: str, question: str, discovered: list[str]) -> InterviewReply {
    if len(question) == 0 or len(question) > 500 { return InterviewReply(message="Ask a question between 1 and 500 characters.", agent="Suspect Interviewer"); }
    if suspect_id == "mara" {
        if "E-01" in discovered or "E-03" in discovered {
            return InterviewReply(message="Mara's composure tightens. 'The lift was put into manual mode for inspection. I remained in the east laboratory.' The secured credential logs place her badge at the archive at 21:14.", agent="Suspect Interviewer", citations=["E-01", "E-03"]);
        }
        return InterviewReply(message="Mara folds her hands. 'I was reviewing samples in the east laboratory. The prototype was secure when I last checked.' Ask about her access or inspect the official logs to test that account.", agent="Suspect Interviewer");
    }
    if suspect_id == "eli" { return InterviewReply(message="Eli answers precisely. 'I stayed at the security desk. The lift override used director credentials; the system records the credential, not who physically carried it.' His statement is not independently verified.", agent="Suspect Interviewer", citations=["S-ELI-01"]); }
    if suspect_id == "june" { return InterviewReply(message="June pauses. 'I was writing a report in the west laboratory. I heard the freight lift, but assumed maintenance had called it in.' Her patent dispute is a motive, not proof of access.", agent="Suspect Interviewer", citations=["S-JUNE-01"]); }
    return InterviewReply(message="That person is not a suspect in this case.", agent="Suspect Interviewer");
}

def:pub evidence_analyst_agent(discovered: list[str]) -> AgentBrief {
    if "E-01" in discovered and "E-03" in discovered {
        return AgentBrief(agent="Evidence Analyst", message="Two independent system records connect the same director credential to route preparation at 21:08 and archive access at 21:14. The credential log does not alone identify the person carrying the case; compare it with the route evidence.", citations=["E-01", "E-03"]);
    }
    if "E-02" in discovered and "E-04" in discovered {
        return AgentBrief(agent="Evidence Analyst", message="The freight-lift residue and corridor still support a transport route, but the camera image does not identify the carrier. Secure the credential records before naming a person.", citations=["E-02", "E-04"]);
    }
    return AgentBrief(agent="Evidence Analyst", message="There is not enough secured evidence to connect a verified access event to the prototype's route. Inspect available records; do not treat a motive as proof.");
}

def:pub theory_coach_agent(theory: str, discovered: list[str]) -> AgentBrief {
    if len(theory) == 0 or len(theory) > 1000 { return AgentBrief(agent="Devil's Advocate", message="Write a theory between 1 and 1,000 characters before testing alternatives."); }
    if "E-01" in discovered and "E-03" in discovered {
        return AgentBrief(agent="Devil's Advocate", message="Alternative to test: a director credential may have been used by someone else. Does your theory explain both the archive-terminal lift override and the 21:14 archive entry, while accounting for the transport trace? Avoid treating motive or the camera silhouette as identification.", citations=["E-01", "E-03"]);
    }
    return AgentBrief(agent="Devil's Advocate", message="Challenge your theory: could another suspect's motive be a red herring? The camera image is not an identification. Secure more records and separate opportunity from proof.");
}

def:pub verdict_explainer_agent(suspect_id: str, evidence_ids: list[str]) -> AgentBrief {
    if not (suspect_id in [s.id for s in missing_prototype_case_data.player_case.public_record.suspects]) {
        return AgentBrief(agent="Verdict Explainer", message="The selected person is not part of this case.");
    }
    if not ("E-01" in evidence_ids) or not ("E-03" in evidence_ids) {
        return AgentBrief(agent="Verdict Explainer", message="The case rules require the archive access record and freight-lift maintenance record as minimum support. The final ruling is made only by the deterministic case engine.", citations=["E-01", "E-03"]);
    }
    return AgentBrief(agent="Verdict Explainer", message="Your submitted records meet the case's minimum evidence threshold. The deterministic case engine will compare the accusation to the fixed case solution; advisory analysis cannot set the culprit.", citations=["E-01", "E-03"]);
}
