import from lib.case_knowledge { is_valid_case_knowledge }
import from services.caseManager { start_missing_prototype_investigation }
import from services.caseLogic { classify_topic, find_contradictions }
import from services.gameApi {
    get_case_board, visit_location, secure_evidence, open_timeline, ask_suspect,
    ask_advisor, submit_theory, file_accusation, restart_investigation
}

def _secure_route(sid: str) -> None {
    visit_location(sid, "archive");
    visit_location(sid, "freight-lift");
    secure_evidence(sid, "E-01");
    secure_evidence(sid, "E-03");
}

test "authored case knowledge is internally consistent" {
    assert is_valid_case_knowledge();
}

test "questions are classified into stable topics" {
    assert classify_topic("mara", "Where were you at 21:14?") == "alibi";
    assert classify_topic("mara", "Why was your badge used?") == "access";
    assert classify_topic("eli", "Did June call you?") == "others";
    assert classify_topic("june", "Did you hear the freight lift?") == "lift";
    assert classify_topic("eli", "Why would you do it?") == "motive";
    assert classify_topic("june", "Tell me about yourself") == "general";
}

test "a fresh board reveals nothing about the case" {
    start_missing_prototype_investigation("p1-fresh-board");
    board = get_case_board("p1-fresh-board");
    assert len(board.evidence) == 0;
    assert len(board.statements) == 0;
    assert len(board.timeline) == 0;
    assert len(board.contradictions) == 0;
    assert board.progress == 0;
    assert board.resolved == False;
    assert board.accusation is None;
    for place in board.locations {
        assert place.visited == False;
        assert len(place.items) == 0;
        assert place.note == "";
    }
}

test "evidence can only be secured after visiting its location" {
    start_missing_prototype_investigation("p1-evidence-gate");
    assert not secure_evidence("p1-evidence-gate", "E-01").accepted;
    assert visit_location("p1-evidence-gate", "archive").accepted;
    board = get_case_board("p1-evidence-gate");
    archive_items = [place.items for place in board.locations if place.id == "archive"][0];
    assert len(archive_items) == 1;
    assert secure_evidence("p1-evidence-gate", "E-01").accepted;
    assert not secure_evidence("p1-evidence-gate", "E-01").accepted;
    assert not secure_evidence("p1-evidence-gate", "S-MARA-01").accepted;
    assert len(get_case_board("p1-evidence-gate").evidence) == 1;
}

test "interviews reveal statements and log contradictions only when evidence supports them" {
    sid = "p1-interview-flow";
    start_missing_prototype_investigation(sid);
    first = ask_suspect(sid, "mara", "Where were you at 21:14?", []);
    assert first.accepted;
    assert first.statement_id == "ST-MARA-ALIBI";
    assert len(first.new_contradictions) == 0;

    visit_location(sid, "archive");
    secure_evidence(sid, "E-01");
    assert len(get_case_board(sid).contradictions) == 1;

    second = ask_suspect(sid, "mara", "Why was your badge in the archive?", ["E-01"]);
    assert second.statement_id == "ST-MARA-ACCESS-2";
    assert second.new_statement;
    again = ask_suspect(sid, "mara", "Why was your badge in the archive?", ["E-01"]);
    assert not again.new_statement;
    assert get_case_board(sid).suspects[0].interview_started;
}

test "interview input is validated on the server" {
    sid = "p1-interview-validation";
    start_missing_prototype_investigation(sid);
    assert not ask_suspect(sid, "mara", "   ", []).accepted;
    assert not ask_suspect(sid, "mara", "x" * 501, []).accepted;
    assert not ask_suspect(sid, "nobody", "Where were you?", []).accepted;
    assert not ask_suspect(sid, "mara", "Explain this.", ["E-03"]).accepted;
    assert len(get_case_board(sid).transcript) == 0;
}

test "red herrings and corroboration resolve without implicating the wrong person" {
    sid = "p1-red-herrings";
    start_missing_prototype_investigation(sid);
    ask_suspect(sid, "eli", "Did June call you at the desk?", []);
    ask_suspect(sid, "june", "Did you hear the freight lift?", []);
    open_timeline(sid);
    board = get_case_board(sid);
    resolved_ids = [lead.id for lead in board.leads if lead.resolved];
    assert "L-03" in resolved_ids;
    corroborated = [entry for entry in board.timeline if entry.kind == "corroborated"];
    assert len(corroborated) == 1;
    assert corroborated[0].time == "21:21";
    assert len(board.contradictions) == 0;
}

test "the timeline stays closed until opened and sorts by time" {
    sid = "p1-timeline";
    start_missing_prototype_investigation(sid);
    _secure_route(sid);
    assert len(get_case_board(sid).timeline) == 0;
    assert open_timeline(sid).accepted;
    entries = get_case_board(sid).timeline;
    assert len(entries) >= 2;
    for index in range(len(entries) - 1) {
        assert entries[index].time <= entries[index + 1].time;
    }
}

test "wrong accusation keeps the case open and correct accusation closes it" {
    sid = "p1-accusation";
    start_missing_prototype_investigation(sid);
    early = file_accusation(sid, "mara", "Too early.", ["E-01", "E-03"]);
    assert not early.accepted;
    _secure_route(sid);

    wrong = file_accusation(sid, "eli", "He controls the logs.", ["E-01", "E-03"]);
    assert wrong.accepted;
    assert not wrong.correct;
    assert not get_case_board(sid).resolved;

    right = file_accusation(sid, "mara", "Her credential opened the lift and the archive.", ["E-01", "E-03"]);
    assert right.accepted;
    assert right.correct;
    closed = get_case_board(sid);
    assert closed.resolved;
    assert closed.accusation is not None;
    assert not ask_suspect(sid, "mara", "Anything else?", []).accepted;
}

test "advisors answer without a model key and the theory flow records a challenge" {
    sid = "p1-advisors";
    start_missing_prototype_investigation(sid);
    assert ask_advisor(sid, "lead", "").agent == "Lead Detective";
    assert ask_advisor(sid, "evidence", "").agent == "Evidence Analyst";
    assert ask_advisor(sid, "advocate", "   ").message.startswith("Write a theory");
    _secure_route(sid);
    result = submit_theory(sid, "Credential misuse", "Someone used Mara's credential to open the lift and archive.", ["E-01", "E-03"], "", 0.6);
    assert result.accepted;
    assert result.advisor_message != "";
    assert len(get_case_board(sid).theories) == 1;
    assert len(get_case_board(sid).agent_log) >= 4;
    try {
        ask_advisor(sid, "oracle", "");
        assert False, "unknown advisor role must be rejected";
    } except ValueError {
        assert True;
    }
}

test "game state is isolated per session and cleared on restart" {
    start_missing_prototype_investigation("p1-iso-a");
    start_missing_prototype_investigation("p1-iso-b");
    ask_suspect("p1-iso-a", "june", "Where were you?", []);
    assert len(get_case_board("p1-iso-a").statements) == 1;
    assert len(get_case_board("p1-iso-b").statements) == 0;
    restart_investigation("p1-iso-a");
    assert len(get_case_board("p1-iso-a").statements) == 0;
    assert len(get_case_board("p1-iso-a").transcript) == 0;
}
