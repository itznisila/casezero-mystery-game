import from lib.missing_prototype_case { missing_prototype_case_data, missing_prototype_canonical_solution }
import from lib.casezero_domain { InvestigationActionKind }

test "rejects invalid canonical case and empty session id" {
    broken_data = missing_prototype_case_data;
    original_title = broken_data.player_case.title;
    broken_data.player_case.title = " ";
    assert not validate_case_data(broken_data);
    broken_data.player_case.title = original_title;

    try {
        initialize_session(missing_prototype_case_data, " ");
        assert False, "empty session id must be rejected";
    } except ValueError {
        assert True;
    }
}

test "initializes empty player-safe case state" {
    session = initialize_session(missing_prototype_case_data, "session-stage-8-init");
    assert session.case_id == "case-001";
    assert session.status == "active";
    assert len(session.discovered_evidence_ids) == 0;
    assert len(session.actions) == 0;
    assert session.accusation is None;

    briefing = get_player_briefing(missing_prototype_case_data);
    assert briefing.title == "The Missing Prototype";
    assert len(briefing.suspect_ids) == 3;
    assert not (missing_prototype_canonical_solution.explanation in briefing.briefing);
    assert not (missing_prototype_canonical_solution.culprit_id in session.discovered_evidence_ids);
}

test "accepts valid evidence and rejects repeated or foreign evidence" {
    session = initialize_session(missing_prototype_case_data, "session-stage-8-evidence");
    inspect = InvestigationCommand(id="a-1", kind=InvestigationActionKind.INSPECT, actor_id="lead", created_at="21:40", target_id="E-01");
    transition = apply_investigation_action(session, inspect);
    assert transition.accepted;
    assert "E-01" in transition.session.discovered_evidence_ids;
    assert len(transition.session.actions) == 1;

    repeated = InvestigationCommand(id="a-2", kind=InvestigationActionKind.INSPECT, actor_id="lead", created_at="21:41", target_id="E-01");
    rejected_repeat = apply_investigation_action(transition.session, repeated);
    assert not rejected_repeat.accepted;
    assert len(rejected_repeat.session.actions) == 1;

    foreign_item = InvestigationCommand(id="a-3", kind=InvestigationActionKind.INSPECT, actor_id="lead", created_at="21:42", target_id="E-99");
    rejected_foreign = apply_investigation_action(transition.session, foreign_item);
    assert not rejected_foreign.accepted;
}

test "records interview and theory only with valid discovered references" {
    session = initialize_session(missing_prototype_case_data, "session-stage-8-interview");
    inspect = InvestigationCommand(id="i-1", kind=InvestigationActionKind.INSPECT, actor_id="lead", created_at="21:40", target_id="E-01");
    session = apply_investigation_action(session, inspect).session;

    interview = InvestigationCommand(id="i-2", kind=InvestigationActionKind.INTERVIEW, actor_id="lead", created_at="21:41", target_id="mara", evidence_ids=["E-01"], content="Who used the archive at 21:14?");
    interview_result = apply_investigation_action(session, interview);
    assert interview_result.accepted;
    assert len(interview_result.session.interview_messages) == 1;

    theory = InvestigationCommand(id="i-3", kind=InvestigationActionKind.FORM_THEORY, actor_id="lead", created_at="21:42", target_id="mara", evidence_ids=["E-01"], title="Access contradiction", content="Mara's stated location conflicts with the badge record.", confidence=0.75);
    theory_result = apply_investigation_action(interview_result.session, theory);
    assert theory_result.accepted;
    assert len(theory_result.session.theories) == 1;

    unsupported = InvestigationCommand(id="i-4", kind=InvestigationActionKind.FORM_THEORY, actor_id="lead", created_at="21:43", evidence_ids=["E-03"], title="Unsecured clue", content="This clue has not been inspected.", confidence=0.5);
    assert not apply_investigation_action(theory_result.session, unsupported).accepted;
}

test "accusation requires canonical evidence and uses fixed culprit" {
    session = initialize_session(missing_prototype_case_data, "session-stage-8-accuse");
    first = InvestigationCommand(id="c-1", kind=InvestigationActionKind.INSPECT, actor_id="lead", created_at="21:40", target_id="E-01");
    session = apply_investigation_action(session, first).session;
    premature = InvestigationCommand(id="c-2", kind=InvestigationActionKind.ACCUSE, actor_id="lead", created_at="21:41", target_id="mara", evidence_ids=["E-01"], content="The badge record contradicts the alibi.");
    assert not apply_investigation_action(session, premature).accepted;

    second = InvestigationCommand(id="c-3", kind=InvestigationActionKind.INSPECT, actor_id="lead", created_at="21:42", target_id="E-03");
    session = apply_investigation_action(session, second).session;
    wrong = InvestigationCommand(id="c-4", kind=InvestigationActionKind.ACCUSE, actor_id="lead", created_at="21:43", target_id="eli", evidence_ids=["E-01", "E-03"], content="The evidence is being reviewed.");
    wrong_result = apply_investigation_action(session, wrong);
    assert wrong_result.accepted;
    assert wrong_result.session.accusation is not None;
    if wrong_result.session.accusation is not None { assert not wrong_result.session.accusation.correct; }
    assert wrong_result.session.status == "active";

    correct = InvestigationCommand(id="c-5", kind=InvestigationActionKind.ACCUSE, actor_id="lead", created_at="21:44", target_id="mara", evidence_ids=["E-01", "E-03"], content="The archive entry and lift override use Mara's credentials.");
    correct_result = apply_investigation_action(session, correct);
    assert correct_result.accepted;
    assert correct_result.session.accusation is not None;
    if correct_result.session.accusation is not None {
        assert correct_result.session.accusation.correct;
        assert correct_result.session.accusation.explanation == missing_prototype_canonical_solution.explanation;
    }
    assert correct_result.session.status == "closed";
}
