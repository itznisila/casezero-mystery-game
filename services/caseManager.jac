import from lib.casezero_domain {
    CaseRecord, InterviewMessage, InvestigationAction, InvestigationActionKind,
    Theory, AccusationResult
}
import from lib.missing_prototype_case {
    PlayerCaseIntroduction, MissingPrototypeCaseData, missing_prototype_case,
    missing_prototype_canonical_solution, missing_prototype_case_data
}

obj PlayerCaseBriefing {
    has case_id: str;
    has title: str;
    has introduction: str;
    has briefing: str;
    has objectives: list[str];
    has location_names: list[str];
    has suspect_ids: list[str];
}

obj InvestigationSession {
    has session_id: str;
    has case_id: str;
    has player_briefing: PlayerCaseBriefing;
    has case_record: CaseRecord;
    has discovered_evidence_ids: list[str] = [];
    has interview_messages: list[InterviewMessage] = [];
    has theories: list[Theory] = [];
    has actions: list[InvestigationAction] = [];
    has accusation: AccusationResult | None = None;
    has status: str = "active";
}

obj InvestigationCommand {
    has id: str;
    has kind: InvestigationActionKind;
    has actor_id: str;
    has created_at: str;
    has target_id: str | None = None;
    has evidence_ids: list[str] = [];
    has content: str = "";
    has title: str = "";
    has confidence: float = 0.0;
}

obj InvestigationTransition {
    has accepted: bool;
    has message: str;
    has session: InvestigationSession;
}

# Validate imported case data before any session can be initialized.
def:pub validate_case_data(case_data: MissingPrototypeCaseData) -> bool {
    if not case_data.is_valid() { return False; }
    if case_data.player_case.case_id != case_data.player_case.public_record.id { return False; }
    if len(case_data.player_case.public_record.suspects) != 3 { return False; }
    if len(case_data.player_case.public_record.evidence) == 0 { return False; }
    if len(case_data.player_case.public_record.timeline) == 0 { return False; }
    return True;
}

def:pub load_case() -> PlayerCaseIntroduction {
    if not validate_case_data(missing_prototype_case_data) { raise ValueError("Canonical case data is missing or invalid."); }
    return missing_prototype_case;
}

def:pub get_player_briefing(case_data: MissingPrototypeCaseData) -> PlayerCaseBriefing {
    if not validate_case_data(case_data) { raise ValueError("Case briefing is unavailable because case data is invalid."); }
    suspect_ids = [suspect.id for suspect in case_data.player_case.public_record.suspects];
    location_names = [location.name for location in case_data.player_case.locations];
    return PlayerCaseBriefing(
        case_id=case_data.player_case.case_id,
        title=case_data.player_case.title,
        introduction=case_data.player_case.introduction,
        briefing=case_data.player_case.briefing,
        objectives=case_data.player_case.initial_objectives,
        location_names=location_names,
        suspect_ids=suspect_ids
    );
}

def:pub initialize_session(case_data: MissingPrototypeCaseData, session_id: str) -> InvestigationSession {
    if not validate_case_data(case_data) { raise ValueError("Cannot initialize an investigation from invalid case data."); }
    if session_id.strip() == "" { raise ValueError("A non-empty session ID is required."); }
    return InvestigationSession(
        session_id=session_id,
        case_id=case_data.player_case.case_id,
        player_briefing=get_player_briefing(case_data),
        case_record=case_data.player_case.public_record,
        discovered_evidence_ids=[]
    );
}

def _command_evidence_is_known(command: InvestigationCommand, case_record: CaseRecord) -> bool {
    for evidence_id in command.evidence_ids {
        if not (evidence_id in [item.id for item in case_record.evidence]) { return False; }
    }
    return True;
}

def _transition_rejected(session: InvestigationSession, message: str) -> InvestigationTransition {
    return InvestigationTransition(accepted=False, message=message, session=session);
}

def _record_action(session: InvestigationSession, command: InvestigationCommand) -> InvestigationAction {
    return InvestigationAction(id=command.id, kind=command.kind, actor_id=command.actor_id, created_at=command.created_at, target_id=command.target_id, evidence_ids=command.evidence_ids);
}

def:pub apply_investigation_action(session: InvestigationSession, command: InvestigationCommand) -> InvestigationTransition {
    if session.status != "active" { return _transition_rejected(session, "This investigation is already closed."); }
    if command.id.strip() == "" or command.actor_id.strip() == "" or command.created_at.strip() == "" {
        return _transition_rejected(session, "Action ID, investigator ID, and timestamp are required.");
    }
    if command.id in [action.id for action in session.actions] { return _transition_rejected(session, "Action IDs must be unique within a session."); }
    if command.kind == InvestigationActionKind.INSPECT {
        if command.target_id is None or command.target_id == "" { return _transition_rejected(session, "Choose an evidence item to inspect."); }
        if not (command.target_id in [item.id for item in session.case_record.evidence]) { return _transition_rejected(session, "That evidence item does not belong to this case."); }
        if command.target_id in session.discovered_evidence_ids { return _transition_rejected(session, "That evidence is already secured."); }
        if len(command.evidence_ids) > 0 { return _transition_rejected(session, "Inspection actions cannot cite additional evidence."); }
        action = _record_action(session, command);
        next_session = InvestigationSession(session_id=session.session_id, case_id=session.case_id, player_briefing=session.player_briefing, case_record=session.case_record, discovered_evidence_ids=session.discovered_evidence_ids + [command.target_id], interview_messages=session.interview_messages, theories=session.theories, actions=session.actions + [action], accusation=session.accusation, status=session.status);
        return InvestigationTransition(accepted=True, message="Evidence secured.", session=next_session);
    }
    if command.kind == InvestigationActionKind.INTERVIEW {
        if command.target_id is None or not (command.target_id in session.player_briefing.suspect_ids) { return _transition_rejected(session, "Choose a suspect from this case."); }
        if command.content.strip() == "" or len(command.content) > 500 { return _transition_rejected(session, "Interview question must contain 1 to 500 characters."); }
        if not _command_evidence_is_known(command, session.case_record) { return _transition_rejected(session, "An interview references evidence outside this case."); }
        for evidence_id in command.evidence_ids {
            if not (evidence_id in session.discovered_evidence_ids) { return _transition_rejected(session, "Only secured evidence can be attached to an interview."); }
        }
        message = InterviewMessage(id=command.id, suspect_id=command.target_id, speaker="investigator", content=command.content.strip(), sent_at=command.created_at, evidence_ids=command.evidence_ids);
        action = _record_action(session, command);
        next_session = InvestigationSession(session_id=session.session_id, case_id=session.case_id, player_briefing=session.player_briefing, case_record=session.case_record, discovered_evidence_ids=session.discovered_evidence_ids, interview_messages=session.interview_messages + [message], theories=session.theories, actions=session.actions + [action], accusation=session.accusation, status=session.status);
        return InvestigationTransition(accepted=True, message="Interview question recorded.", session=next_session);
    }
    if command.kind == InvestigationActionKind.FORM_THEORY {
        if command.title.strip() == "" or command.content.strip() == "" { return _transition_rejected(session, "A theory needs a title and summary."); }
        if len(command.title) > 120 or len(command.content) > 1000 { return _transition_rejected(session, "Theory title or summary exceeds its limit."); }
        if command.confidence < 0.0 or command.confidence > 1.0 { return _transition_rejected(session, "Theory confidence must be between 0 and 1."); }
        if command.target_id is not None and not (command.target_id in session.player_briefing.suspect_ids) { return _transition_rejected(session, "A theory references a suspect outside this case."); }
        if not _command_evidence_is_known(command, session.case_record) { return _transition_rejected(session, "A theory references evidence outside this case."); }
        for evidence_id in command.evidence_ids {
            if not (evidence_id in session.discovered_evidence_ids) { return _transition_rejected(session, "Only secured evidence can support a theory."); }
        }
        suspect_ids: list[str] = [];
        if command.target_id is not None { suspect_ids = [command.target_id]; }
        theory = Theory(id=command.id, title=command.title.strip(), summary=command.content.strip(), evidence_ids=command.evidence_ids, suspect_ids=suspect_ids, confidence=command.confidence);
        action = _record_action(session, command);
        next_session = InvestigationSession(session_id=session.session_id, case_id=session.case_id, player_briefing=session.player_briefing, case_record=session.case_record, discovered_evidence_ids=session.discovered_evidence_ids, interview_messages=session.interview_messages, theories=session.theories + [theory], actions=session.actions + [action], accusation=session.accusation, status=session.status);
        return InvestigationTransition(accepted=True, message="Theory recorded.", session=next_session);
    }
    if command.kind == InvestigationActionKind.ACCUSE {
        if command.target_id is None or not (command.target_id in session.player_briefing.suspect_ids) { return _transition_rejected(session, "Choose a suspect from this case."); }
        if command.content.strip() == "" or len(command.content) > 1000 { return _transition_rejected(session, "An accusation explanation must contain 1 to 1,000 characters."); }
        if not _command_evidence_is_known(command, session.case_record) { return _transition_rejected(session, "An accusation references evidence outside this case."); }
        for evidence_id in command.evidence_ids {
            if not (evidence_id in session.discovered_evidence_ids) { return _transition_rejected(session, "Only secured evidence can support an accusation."); }
        }
        if not ("E-01" in command.evidence_ids) or not ("E-03" in command.evidence_ids) { return _transition_rejected(session, "Cite both the archive access log and freight-lift maintenance log before accusing anyone."); }
        culprit_id = missing_prototype_canonical_solution.culprit_id;
        is_correct = command.target_id == culprit_id;
        result_message = "Accusation upheld. Case closed." if is_correct else "Accusation not upheld. The case remains open.";
        result_explanation = missing_prototype_canonical_solution.explanation if is_correct else "";
        result = AccusationResult(valid=True, correct=is_correct, message=result_message, suspect_id=command.target_id, explanation=result_explanation, evidence_ids=command.evidence_ids, score=100 if is_correct else 0);
        action = _record_action(session, command);
        next_status = "closed" if is_correct else "active";
        next_session = InvestigationSession(session_id=session.session_id, case_id=session.case_id, player_briefing=session.player_briefing, case_record=session.case_record, discovered_evidence_ids=session.discovered_evidence_ids, interview_messages=session.interview_messages, theories=session.theories, actions=session.actions + [action], accusation=result, status=next_status);
        return InvestigationTransition(accepted=True, message=result_message, session=next_session);
    }
    return _transition_rejected(session, "This action is not allowed.");
}
