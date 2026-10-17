obj Clue {
    has id: str;
    has title: str;
    has summary: str;
    has detail: str;
    has time: str;
    has suspect: str;
}

obj Suspect {
    has id: str;
    has name: str;
    has role: str;
    has profile: str;
    has alibi: str;
    has motive: str;
}

obj CaseFile {
    has title: str;
    has briefing: str;
    has objective: str;
    has suspects: list[Suspect];
    has clues: list[Clue];
    has timeline: list[str];
    has mode: str;
}

glob CASE_CLUES: list[Clue] = [
    Clue(id="E-01", title="Access log", summary="Mara's badge entered the archive at 21:14.", detail="The lab's badge reader recorded research director Mara Voss entering the prototype archive at 21:14. Her statement placed her in the east wing from 21:00 onward.", time="21:14", suspect="Mara Voss"),
    Clue(id="E-02", title="Cooling residue", summary="A cryogenic case left a trace in the freight lift.", detail="A thin ring of cryogenic condensate was found on the freight lift floor. The prototype's transport case leaves this residue for roughly twenty minutes after use.", time="21:20", suspect="Mara Voss"),
    Clue(id="E-03", title="Maintenance ticket", summary="The freight lift override was requested with Mara's credentials.", detail="A sealed maintenance ticket shows the freight lift was put into manual mode at 21:08 using Mara's director credentials. The request was made from the archive terminal.", time="21:08", suspect="Mara Voss"),
    Clue(id="E-04", title="Security still", summary="A reflection places a silver case near the freight lift.", detail="A corridor camera reflection at 21:22 shows a person carrying the silver prototype case toward the freight exit. The figure wears a lab coat; the image does not identify a face.", time="21:22", suspect="Unknown")
];

glob CASE_SUSPECTS: list[Suspect] = [
    Suspect(id="mara", name="Mara Voss", role="Research director", profile="Exacting, composed, and protective of her team's work. She had administrator access to every lab system.", alibi="Says she was reviewing samples in the east wing from 21:00 to 21:30.", motive="The prototype's launch was delayed, putting her research division's funding at risk."),
    Suspect(id="eli", name="Eli Navarro", role="Security engineer", profile="A careful systems thinker who speaks in precise, short answers. He maintains the lab's access controls.", alibi="Says he was monitoring the security desk throughout the incident.", motive="He had recently been reprimanded after a security audit."),
    Suspect(id="june", name="Dr. June Park", role="Materials scientist", profile="Curious and candid, but reluctant to discuss a pending patent dispute.", alibi="Says she was preparing a materials report in the west lab.", motive="Her independent materials patent overlaps with the prototype's key component.")
];

def:pub getCase() -> CaseFile {
    return CaseFile(title="The Missing Prototype", briefing="At 21:30, the Helix prototype vanished from a locked research archive. No forced entry. Three people had access, and one official timeline does not hold.", objective="Find the access trail, test each alibi against the evidence, and name the person responsible.", suspects=CASE_SUSPECTS, clues=CASE_CLUES, timeline=["21:00 · Mara says she is in the east wing.", "21:08 · Freight lift switched to manual mode.", "21:14 · A director badge enters the archive.", "21:20 · Cryogenic residue appears in the freight lift.", "21:22 · A silver case moves toward the freight exit.", "21:30 · The prototype is reported missing."], mode="DEMO MODE · deterministic case responses");
}

def:pub discoverClue(clue_id: str) -> Clue | None {
    for clue in CASE_CLUES {
        if clue.id == clue_id { return clue; }
    }
    return None;
}

def:pub interviewSuspect(suspect_id: str, question: str, evidence_id: str) -> str {
    if len(question) > 500 { return "Keep the question under 500 characters so the interview stays focused."; }
    if suspect_id == "mara" {
        if evidence_id == "E-01" or evidence_id == "E-03" { return "Mara's composure slips. 'I had access, yes. The override was for a routine lift inspection. I never entered the archive.' The access record places her badge inside it at 21:14."; }
        return "Mara folds her hands. 'I was reviewing samples in the east wing. The prototype was secure when I last checked.' Her account can be tested against the access log and maintenance ticket.";
    }
    if suspect_id == "eli" { return "Eli answers evenly. 'I stayed at the security desk. The lift override used director credentials; my console logs can confirm the request, but not who held the badge.'"; }
    if suspect_id == "june" { return "June pauses. 'I was in the west lab writing a report. I heard the freight lift, but assumed maintenance had called it in.' She cannot identify who used it."; }
    return "That interview request does not match a suspect in this case.";
}

def:pub planNextAction(discovered: list[str], completed_interviews: list[str]) -> str {
    if not ("E-01" in discovered) { return "Inspect the archive access log. It can test the director's stated whereabouts."; }
    if not ("E-03" in discovered) { return "Inspect the maintenance ticket. Identify who authorized the freight lift override."; }
    if not ("mara" in completed_interviews) { return "Interview Mara and ask about the archive entry and lift override."; }
    if not ("E-02" in discovered) { return "Inspect the freight lift residue to verify the prototype's route."; }
    return "Compare Mara's account with the access record and freight-lift evidence before accusing anyone.";
}

def:pub accuseSuspect(suspect_id: str, explanation: str, discovered: list[str]) -> dict {
    if len(explanation) > 1000 { return {"valid": False, "correct": False, "message": "Keep the case note under 1,000 characters."}; }
    if suspect_id != "mara" {
        return {"valid": True, "correct": False, "message": "The evidence does not support that accusation. Recheck the badge entry and lift override before closing the case."};
    }
    if not ("E-01" in discovered) or not ("E-03" in discovered) {
        return {"valid": True, "correct": False, "message": "Your suspect is correct, but the file is not ready. Discover both the access log and maintenance ticket to support the charge."};
    }
    return {"valid": True, "correct": True, "culprit": "Mara Voss", "score": 100, "message": "CASE CLOSED. Mara Voss used her director credentials to switch the freight lift to manual mode, entered the archive, and moved the prototype out in its silver cryogenic case. E-03 establishes preparation, E-01 contradicts her alibi, and E-02 confirms the case traveled by freight lift. Eli's credentials were not used; June's patent dispute is motive without a link to the route."};
}
