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

test "provides canonical spoiler-safe briefing and starts a session" {
    briefing = get_missing_prototype_briefing();
    assert briefing.case_id == "case-001";
    assert briefing.title == "The Missing Prototype";
    assert len(briefing.objectives) == 3;
    assert len(briefing.known_facts) > 0;
    assert len(briefing.location_names) == 6;
    assert len(briefing.suspect_ids) == 3;
    assert not (missing_prototype_canonical_solution.explanation in briefing.briefing);
    assert not (missing_prototype_canonical_solution.explanation in briefing.known_facts);

    receipt = start_missing_prototype_investigation("stage11-brief-start");
    assert receipt.session_id == "stage11-brief-start";
    assert receipt.case_id == briefing.case_id;
    assert receipt.status == "active";
    assert receipt.message != "";

    try {
        start_missing_prototype_investigation(" ");
        assert False, "blank session ID should be rejected";
    } except ValueError {
        assert True;
    }
}

test "returns the public briefing and starts a validated session receipt" {
    briefing = get_missing_prototype_briefing();
    facts = get_missing_prototype_known_facts();
    assert briefing.case_id == "case-001";
    assert briefing.title == "The Missing Prototype";
    assert len(briefing.objectives) == 3;
    assert len(facts.known_facts) == 4;
    assert not (missing_prototype_canonical_solution.explanation in facts.briefing);
    assert not (missing_prototype_canonical_solution.explanation in briefing.briefing);
    receipt = start_missing_prototype_investigation("stage11-start");
    assert receipt.session_id == "stage11-start";
    assert receipt.case_id == briefing.case_id;
    assert receipt.status == "active";
    assert receipt.message != "";
}

test "suspect overview displays all canonical public profiles consistently" {
    receipt = start_missing_prototype_investigation("stage12-profiles");
    profiles = get_suspect_overview(receipt.session_id);
    assert len(profiles) == 3;
    assert profiles[0].id == "mara";
    assert profiles[1].id == "eli";
    assert profiles[2].id == "june";
    for profile in profiles {
        assert profile.name.strip() != "";
        assert profile.role.strip() != "";
        assert profile.profile.strip() != "";
        assert not profile.interview_started;
    }
}

test "suspect overview shows all canonical public profiles and live interview progress" {
    receipt = start_missing_prototype_investigation("stage12-suspects");
    initial_profiles = get_suspect_overview(receipt.session_id);
    assert len(initial_profiles) == 3;
    assert initial_profiles[0].id == "mara";
    assert initial_profiles[0].role == "Research director";
    assert not initial_profiles[0].interview_started;
    assert not (missing_prototype_canonical_solution.explanation in initial_profiles[0].profile);
    interview = InvestigationCommand(id="s-1", kind=InvestigationActionKind.INTERVIEW, actor_id="lead", created_at="21:40", target_id="mara", content="Where were you at 21:14?");
    result = apply_investigation_action(_ACTIVE_SESSIONS[receipt.session_id], interview);
    assert result.accepted;
    updated_profiles = get_suspect_overview(receipt.session_id);
    assert updated_profiles[0].interview_started;
    assert not updated_profiles[1].interview_started;
}

test "initializes empty investigation state with player-safe briefing" {
    session = initialize_session(missing_prototype_case_data, "stage10-init");
    assert session.case_id == "case-001";
    assert session.status == "active";
    assert not session.resolved;
    assert len(session.discovered_evidence_ids) == 0;
    assert len(session.interviewed_suspect_ids) == 0;
    assert len(session.visited_location_ids) == 0;
    assert not session.timeline_accessed;
    assert len(session.actions) == 0;
    assert session.accusation is None;
    assert not (missing_prototype_canonical_solution.explanation in session.player_briefing.briefing);
}

test "valid actions advance state and repeated unauthorized actions preserve it" {
    session = initialize_session(missing_prototype_case_data, "stage10-progress");
    bad_location = InvestigationCommand(id="p-1", kind=InvestigationActionKind.VISIT_LOCATION, actor_id="lead", created_at="21:35", target_id="secret-room");
    rejected_location = apply_investigation_action(session, bad_location);
    assert not rejected_location.accepted;
    assert len(rejected_location.session.visited_location_ids) == 0;
    assert len(rejected_location.session.actions) == 0;

    visit_command = InvestigationCommand(id="p-2", kind=InvestigationActionKind.VISIT_LOCATION, actor_id="lead", created_at="21:36", target_id="archive");
    visit_result = apply_investigation_action(session, visit_command);
    assert visit_result.accepted;
    assert "archive" in visit_result.session.visited_location_ids;

    repeated_visit_command = InvestigationCommand(id="p-3", kind=InvestigationActionKind.VISIT_LOCATION, actor_id="lead", created_at="21:37", target_id="archive");
    repeated_visit_result = apply_investigation_action(visit_result.session, repeated_visit_command);
    assert not repeated_visit_result.accepted;
    assert len(repeated_visit_result.session.visited_location_ids) == 1;
    assert len(repeated_visit_result.session.actions) == 1;

    timeline = InvestigationCommand(id="p-4", kind=InvestigationActionKind.ACCESS_TIMELINE, actor_id="lead", created_at="21:38");
    timeline_result = apply_investigation_action(repeated_visit_result.session, timeline);
    assert timeline_result.accepted;
    assert timeline_result.session.timeline_accessed;

    repeated_timeline = InvestigationCommand(id="p-5", kind=InvestigationActionKind.ACCESS_TIMELINE, actor_id="lead", created_at="21:39");
    assert not apply_investigation_action(timeline_result.session, repeated_timeline).accepted;
}

test "interview progress tracks distinct authorized suspects" {
    session = initialize_session(missing_prototype_case_data, "stage10-interviews");
    invalid = InvestigationCommand(id="m-1", kind=InvestigationActionKind.INTERVIEW, actor_id="lead", created_at="21:40", target_id="unknown", content="Where were you?");
    rejected = apply_investigation_action(session, invalid);
    assert not rejected.accepted;
    assert len(rejected.session.interviewed_suspect_ids) == 0;
    assert len(rejected.session.interview_messages) == 0;

    question = InvestigationCommand(id="m-2", kind=InvestigationActionKind.INTERVIEW, actor_id="lead", created_at="21:41", target_id="mara", content="Who entered the archive?");
    first = apply_investigation_action(session, question);
    assert first.accepted;
    assert "mara" in first.session.interviewed_suspect_ids;
    again = InvestigationCommand(id="m-3", kind=InvestigationActionKind.INTERVIEW, actor_id="lead", created_at="21:42", target_id="mara", content="Can you clarify your timeline?");
    second = apply_investigation_action(first.session, again);
    assert second.accepted;
    assert len(second.session.interviewed_suspect_ids) == 1;
    assert len(second.session.interview_messages) == 2;
}

test "evidence citations and action IDs are validated without state corruption" {
    session = initialize_session(missing_prototype_case_data, "stage10-validation");
    duplicate_id = InvestigationCommand(id="x-1", kind=InvestigationActionKind.ACCESS_TIMELINE, actor_id="lead", created_at="21:40");
    accessed = apply_investigation_action(session, duplicate_id);
    assert accessed.accepted;
    duplicate_action = InvestigationCommand(id="x-1", kind=InvestigationActionKind.VISIT_LOCATION, actor_id="lead", created_at="21:41", target_id="archive");
    rejected = apply_investigation_action(accessed.session, duplicate_action);
    assert not rejected.accepted;
    assert rejected.session.timeline_accessed;
    assert len(rejected.session.visited_location_ids) == 0;

    invalid_reference = InvestigationCommand(id="x-2", kind=InvestigationActionKind.FORM_THEORY, actor_id="lead", created_at="21:42", target_id="unknown", title="Unsupported", content="Unsupported suspect theory", confidence=0.4);
    assert not apply_investigation_action(accessed.session, invalid_reference).accepted;
}

test "only correct authoritative accusation resolves and resolution locks session" {
    session = initialize_session(missing_prototype_case_data, "stage10-resolution");
    for (action_id, clue_id, time) in [("r-1", "E-01", "21:40"), ("r-2", "E-03", "21:41")] {
        inspect = InvestigationCommand(id=action_id, kind=InvestigationActionKind.INSPECT, actor_id="lead", created_at=time, target_id=clue_id);
        result = apply_investigation_action(session, inspect);
        assert result.accepted;
        session = result.session;
    }
    incorrect = InvestigationCommand(id="r-3", kind=InvestigationActionKind.ACCUSE, actor_id="lead", created_at="21:42", target_id="eli", evidence_ids=["E-01", "E-03"], content="Test the official outcome.");
    wrong_result = apply_investigation_action(session, incorrect);
    assert wrong_result.accepted;
    assert not wrong_result.session.resolved;
    assert wrong_result.session.status == "active";

    correct = InvestigationCommand(id="r-4", kind=InvestigationActionKind.ACCUSE, actor_id="lead", created_at="21:43", target_id="mara", evidence_ids=["E-01", "E-03"], content="The access and maintenance records support the accusation.");
    correct_result = apply_investigation_action(wrong_result.session, correct);
    assert correct_result.accepted;
    assert correct_result.session.resolved;
    assert correct_result.session.status == "closed";
    assert correct_result.session.accusation is not None;
    if correct_result.session.accusation is not None { assert correct_result.session.accusation.explanation == missing_prototype_canonical_solution.explanation; }

    late_visit = InvestigationCommand(id="r-5", kind=InvestigationActionKind.VISIT_LOCATION, actor_id="lead", created_at="21:44", target_id="archive");
    locked = apply_investigation_action(correct_result.session, late_visit);
    assert not locked.accepted;
    assert locked.session.resolved;
    assert len(locked.session.actions) == len(correct_result.session.actions);
}
