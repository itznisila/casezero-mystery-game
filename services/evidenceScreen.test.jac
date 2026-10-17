import from services.caseManager { InvestigationStartReceipt, EvidenceCollection, start_missing_prototype_investigation, get_session_evidence_api, discover_session_evidence_api }

test "evidence screen starts empty, reveals a discovered clue, and rejects duplicates" {
    receipt = start_missing_prototype_investigation("evidence-screen-test");
    initial = get_session_evidence_api(receipt.session_id);
    assert len(initial.discovered) == 0;
    assert len(initial.available_ids) == 4;
    assert not ("S-MARA-01" in initial.available_ids);

    assert discover_session_evidence_api(receipt.session_id, "E-01");
    discovered = get_session_evidence_api(receipt.session_id);
    assert len(discovered.discovered) == 1;
    assert discovered.discovered[0].id == "E-01";
    assert discovered.discovered[0].title == "Archive access record";
    assert discovered.discovered[0].detail != "";
    assert not ("E-01" in discovered.available_ids);
    assert not discover_session_evidence_api(receipt.session_id, "E-01");
    assert len(get_session_evidence_api(receipt.session_id).discovered) == 1;
}

test "evidence clues remain isolated per investigation" {
    first = start_missing_prototype_investigation("evidence-isolation-one");
    second = start_missing_prototype_investigation("evidence-isolation-two");
    assert discover_session_evidence_api(first.session_id, "E-03");
    assert len(get_session_evidence_api(first.session_id).discovered) == 1;
    assert len(get_session_evidence_api(second.session_id).discovered) == 0;
}
