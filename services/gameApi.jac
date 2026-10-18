import from lib.casezero_domain { EvidenceItem, Theory, AccusationResult, InvestigationActionKind }
import from lib.missing_prototype_case { missing_prototype_case }
import from lib.case_knowledge { LOCATION_EVIDENCE, LOCATION_NOTES, PERSONAS }
import from lib.casezero_session {
    InvestigationSession, InvestigationCommand, InvestigationStartReceipt, SuspectPublicProfile
}
import from services.caseManager {
    get_investigation_session, submit_investigation_action, get_suspect_overview,
    discover_session_evidence_api, reset_missing_prototype_investigation
}
import from services.caseLogic {
    ContradictionFinding, LeadStatus, TimelineEntry, statement_by_id, run_interview,
    find_contradictions, get_lead_statuses, build_timeline, compute_progress, all_evidence_ids
}
import from services.advisors {
    AdvisorReply, AdvisorInfo, list_advisors, voice_suspect, advise_lead_detective,
    advise_evidence_analyst, advise_devils_advocate
}

# This module is the only API the game screens need. It never returns hidden case data:
# evidence, statements, timeline entries, and contradictions appear only after the player
# has earned them in that session. The culprit is never sent to the client until the
# deterministic case engine upholds a correct accusation.

obj TranscriptLine {
    has id: str;
    has suspect_id: str;
    has speaker: str;
    has text: str;
    has evidence_ids: list[str] = [];
    has statement_id: str = "";
    has mode: str = "rules-only";
}

obj AgentLogEntry {
    has id: str;
    has agent: str;
    has summary: str;
    has mode: str;
    has citations: list[str] = [];
}

obj GameState {
    has session_id: str;
    has revealed_statement_ids: list[str] = [];
    has transcript: list[TranscriptLine] = [];
    has agent_log: list[AgentLogEntry] = [];
    has counter: int = 0;
}

obj LockedItem {
    has id: str;
    has title: str;
}

obj LocationView {
    has id: str;
    has name: str;
    has description: str;
    has visited: bool;
    has note: str;
    has items: list[LockedItem];
}

obj RevealedStatement {
    has id: str;
    has suspect_id: str;
    has topic: str;
    has kind: str;
    has line: str;
}

obj CaseBoard {
    has session_id: str;
    has status: str;
    has resolved: bool;
    has progress: int;
    has timeline_open: bool;
    has evidence_total: int;
    has evidence: list[EvidenceItem];
    has locations: list[LocationView];
    has statements: list[RevealedStatement];
    has timeline: list[TimelineEntry];
    has contradictions: list[ContradictionFinding];
    has leads: list[LeadStatus];
    has suspects: list[SuspectPublicProfile];
    has transcript: list[TranscriptLine];
    has agent_log: list[AgentLogEntry];
    has theories: list[Theory];
    has accusation: AccusationResult | None;
}

obj InterviewTurn {
    has accepted: bool;
    has message: str;
    has suspect_name: str = "";
    has reply: str = "";
    has topic: str = "";
    has statement_id: str = "";
    has new_statement: bool = False;
    has citations: list[str] = [];
    has mode: str = "rules-only";
    has new_contradictions: list[str] = [];
}

obj ActionResult {
    has accepted: bool;
    has message: str;
    has correct: bool = False;
    has advisor_message: str = "";
}

glob _GAME_STATES: dict[str, GameState] = {};

def _state(session_id: str) -> GameState {
    if not (session_id in _GAME_STATES) { _GAME_STATES[session_id] = GameState(session_id=session_id); }
    return _GAME_STATES[session_id];
}

def _require_session(session_id: str) -> InvestigationSession {
    found = get_investigation_session(session_id);
    if found is None { raise ValueError("Investigation session was not found."); }
    return found;
}

def _log(state: GameState, agent: str, summary: str, mode: str, citations: list[str]) -> None {
    state.counter = state.counter + 1;
    entry = AgentLogEntry(id="log-" + str(state.counter), agent=agent, summary=summary, mode=mode, citations=citations);
    state.agent_log = state.agent_log + [entry];
}

def _rejected_turn(message: str) -> InterviewTurn {
    return InterviewTurn(accepted=False, message=message);
}

def _rejected(message: str) -> ActionResult {
    return ActionResult(accepted=False, message=message);
}

def _location_of(evidence_id: str) -> str {
    for loc_id in LOCATION_EVIDENCE {
        if evidence_id in LOCATION_EVIDENCE[loc_id] { return loc_id; }
    }
    return "";
}

def _location_name(location_id: str) -> str {
    for loc in missing_prototype_case.locations {
        if loc.id == location_id { return loc.name; }
    }
    return "that location";
}

def _evidence_title(evidence_id: str) -> str {
    for item in missing_prototype_case.public_record.evidence {
        if item.id == evidence_id { return item.title; }
    }
    return evidence_id;
}

def _suspect_name(suspect_id: str) -> str {
    for suspect in missing_prototype_case.public_record.suspects {
        if suspect.id == suspect_id { return suspect.name; }
    }
    return "Unknown";
}

def:pub get_case_board(session_id: str) -> CaseBoard {
    session = _require_session(session_id);
    state = _state(session_id);
    discovered = session.discovered_evidence_ids;
    revealed = state.revealed_statement_ids;
    findings = find_contradictions(discovered, revealed);
    leads = get_lead_statuses(discovered, revealed, [f.id for f in findings]);

    secured: list[EvidenceItem] = [];
    registry = missing_prototype_case.public_record.evidence;
    for evidence_id in discovered {
        for item in registry {
            if item.id == evidence_id { secured.append(item); }
        }
    }

    places: list[LocationView] = [];
    for loc in missing_prototype_case.locations {
        visited = loc.id in session.visited_location_ids;
        note = "";
        items: list[LockedItem] = [];
        if visited {
            note = LOCATION_NOTES[loc.id];
            for evidence_id in LOCATION_EVIDENCE[loc.id] {
                if not (evidence_id in discovered) { items.append(LockedItem(id=evidence_id, title=_evidence_title(evidence_id))); }
            }
        }
        places.append(LocationView(id=loc.id, name=loc.name, description=loc.description, visited=visited, note=note, items=items));
    }

    heard: list[RevealedStatement] = [];
    for statement_id in revealed {
        st = statement_by_id(statement_id);
        if st is not None { heard.append(RevealedStatement(id=st.id, suspect_id=st.suspect_id, topic=st.topic, kind=st.kind, line=st.line)); }
    }

    timeline: list[TimelineEntry] = [];
    if session.timeline_accessed { timeline = build_timeline(discovered, revealed); }

    return CaseBoard(
        session_id=session_id,
        status=session.status,
        resolved=session.resolved,
        progress=compute_progress(discovered, revealed, findings, leads),
        timeline_open=session.timeline_accessed,
        evidence_total=len(all_evidence_ids()),
        evidence=secured,
        locations=places,
        statements=heard,
        timeline=timeline,
        contradictions=findings,
        leads=leads,
        suspects=get_suspect_overview(session_id),
        transcript=state.transcript,
        agent_log=state.agent_log,
        theories=session.theories,
        accusation=session.accusation
    );
}

def:pub visit_location(session_id: str, location_id: str) -> ActionResult {
    session = _require_session(session_id);
    if session.resolved { return _rejected("This case is closed."); }
    if not (location_id in LOCATION_NOTES) { return _rejected("Choose a location in this case."); }
    if location_id in session.visited_location_ids {
        return ActionResult(accepted=True, message=LOCATION_NOTES[location_id]);
    }
    state = _state(session_id);
    state.counter = state.counter + 1;
    command = InvestigationCommand(id=session_id + "-visit-" + location_id, kind=InvestigationActionKind.VISIT_LOCATION, actor_id="lead-investigator", created_at="21:40", target_id=location_id);
    transition = submit_investigation_action(session_id, command);
    if not transition.accepted { return _rejected(transition.message); }
    return ActionResult(accepted=True, message=LOCATION_NOTES[location_id]);
}

def:pub secure_evidence(session_id: str, evidence_id: str) -> ActionResult {
    session = _require_session(session_id);
    if session.resolved { return _rejected("This case is closed."); }
    location_id = _location_of(evidence_id);
    if location_id == "" { return _rejected("That item is not part of this case."); }
    if evidence_id in session.discovered_evidence_ids { return _rejected("That item is already secured."); }
    if not (location_id in session.visited_location_ids) {
        return _rejected("Visit " + _location_name(location_id) + " before securing that item.");
    }
    if not discover_session_evidence_api(session_id, evidence_id) { return _rejected("The item could not be secured."); }
    return ActionResult(accepted=True, message=_evidence_title(evidence_id) + " secured.");
}

def:pub open_timeline(session_id: str) -> ActionResult {
    session = _require_session(session_id);
    if session.resolved { return _rejected("This case is closed."); }
    if session.timeline_accessed { return ActionResult(accepted=True, message="Official timeline is open."); }
    command = InvestigationCommand(id=session_id + "-timeline", kind=InvestigationActionKind.ACCESS_TIMELINE, actor_id="lead-investigator", created_at="21:40");
    transition = submit_investigation_action(session_id, command);
    if not transition.accepted { return _rejected(transition.message); }
    return ActionResult(accepted=True, message="Official timeline opened.");
}

def:pub ask_suspect(session_id: str, suspect_id: str, question: str, evidence_ids: list[str]) -> InterviewTurn {
    session = _require_session(session_id);
    state = _state(session_id);
    text = question.strip();
    if session.resolved { return _rejected_turn("This case is closed."); }
    if text == "" or len(text) > 500 { return _rejected_turn("Ask a question between 1 and 500 characters."); }
    if not (suspect_id in session.player_briefing.suspect_ids) { return _rejected_turn("Choose a suspect from this case."); }
    if len(evidence_ids) > 4 { return _rejected_turn("Present at most four items at once."); }
    for evidence_id in evidence_ids {
        if not (evidence_id in session.discovered_evidence_ids) { return _rejected_turn("Only secured evidence can be presented."); }
    }

    before = [f.id for f in find_contradictions(session.discovered_evidence_ids, state.revealed_statement_ids)];
    state.counter = state.counter + 1;
    turn_id = session_id + "-ask-" + str(state.counter);
    command = InvestigationCommand(id=turn_id, kind=InvestigationActionKind.INTERVIEW, actor_id="lead-investigator", created_at="21:40", target_id=suspect_id, evidence_ids=evidence_ids, content=text);
    transition = submit_investigation_action(session_id, command);
    if not transition.accepted { return _rejected_turn(transition.message); }

    outcome = run_interview(suspect_id, text, evidence_ids);
    persona = PERSONAS[suspect_id];
    reply = voice_suspect(persona, outcome, text, session.discovered_evidence_ids);
    is_new = outcome.statement_id != "" and not (outcome.statement_id in state.revealed_statement_ids);
    if is_new { state.revealed_statement_ids = state.revealed_statement_ids + [outcome.statement_id]; }

    asked = TranscriptLine(id=turn_id + "-q", suspect_id=suspect_id, speaker="investigator", text=text, evidence_ids=evidence_ids);
    answered = TranscriptLine(id=turn_id + "-a", suspect_id=suspect_id, speaker=suspect_id, text=reply.message, statement_id=outcome.statement_id, mode=reply.mode);
    state.transcript = state.transcript + [asked, answered];
    _log(state, "Suspect Interviewer", _suspect_name(suspect_id) + " answered a question about " + outcome.topic + ".", reply.mode, outcome.citations);

    after = find_contradictions(session.discovered_evidence_ids, state.revealed_statement_ids);
    new_titles = [f.title for f in after if not (f.id in before)];
    return InterviewTurn(accepted=True, message="Answer recorded.", suspect_name=_suspect_name(suspect_id), reply=reply.message, topic=outcome.topic, statement_id=outcome.statement_id, new_statement=is_new, citations=outcome.citations, mode=reply.mode, new_contradictions=new_titles);
}

def:pub ask_advisor(session_id: str, role: str, text: str) -> AdvisorReply {
    session = _require_session(session_id);
    state = _state(session_id);
    discovered = session.discovered_evidence_ids;
    revealed = state.revealed_statement_ids;
    reply = AdvisorReply(agent="", message="");
    if role == "lead" {
        reply = advise_lead_detective(discovered, revealed);
    } elif role == "evidence" {
        reply = advise_evidence_analyst(discovered, revealed);
    } elif role == "advocate" {
        reply = advise_devils_advocate(text, discovered, revealed);
    } else {
        raise ValueError("Unknown advisor role.");
    }
    _log(state, reply.agent, reply.message, reply.mode, reply.citations);
    return reply;
}

def:pub submit_theory(session_id: str, title: str, summary: str, evidence_ids: list[str], suspect_id: str, confidence: float) -> ActionResult {
    session = _require_session(session_id);
    state = _state(session_id);
    state.counter = state.counter + 1;
    target: str | None = None;
    if suspect_id != "" { target = suspect_id; }
    command = InvestigationCommand(id=session_id + "-theory-" + str(state.counter), kind=InvestigationActionKind.FORM_THEORY, actor_id="lead-investigator", created_at="21:40", target_id=target, evidence_ids=evidence_ids, content=summary, title=title, confidence=confidence);
    transition = submit_investigation_action(session_id, command);
    if not transition.accepted { return _rejected(transition.message); }
    challenge = advise_devils_advocate(summary, session.discovered_evidence_ids, state.revealed_statement_ids);
    _log(state, challenge.agent, challenge.message, challenge.mode, challenge.citations);
    return ActionResult(accepted=True, message="Theory recorded.", advisor_message=challenge.message);
}

def:pub file_accusation(session_id: str, suspect_id: str, explanation: str, evidence_ids: list[str]) -> ActionResult {
    _require_session(session_id);
    state = _state(session_id);
    state.counter = state.counter + 1;
    command = InvestigationCommand(id=session_id + "-accuse-" + str(state.counter), kind=InvestigationActionKind.ACCUSE, actor_id="lead-investigator", created_at="21:40", target_id=suspect_id, evidence_ids=evidence_ids, content=explanation);
    transition = submit_investigation_action(session_id, command);
    if not transition.accepted { return _rejected(transition.message); }
    correct = False;
    result = transition.session.accusation;
    if result is not None { correct = result.correct; }
    return ActionResult(accepted=True, message=transition.message, correct=correct);
}

def:pub restart_investigation(session_id: str) -> InvestigationStartReceipt {
    receipt = reset_missing_prototype_investigation(session_id);
    _GAME_STATES[session_id] = GameState(session_id=session_id);
    return receipt;
}
