import from lib.missing_prototype_case { missing_prototype_case }

test "registry contains official physical records and statements" {
    items = initial_evidence();
    assert is_valid_evidence_registry(items);
    assert len(items) == 7;
    assert "E-01" in [item.id for item in items];
    assert "E-02" in [item.id for item in items];
    assert "E-03" in [item.id for item in items];
    assert "E-04" in [item.id for item in items];
    assert "S-MARA-01" in [item.id for item in items];
    assert "S-ELI-01" in [item.id for item in items];
    assert "S-JUNE-01" in [item.id for item in items];
    assert "no record linking him" in items[5].detail;
    assert "no evidence linking her" in items[6].detail;
}

test "initializes isolated ledgers and discovers only predefined clues" {
    items = initial_evidence();
    ledger_a = initialize_evidence_ledger("ev-session-a", missing_prototype_case.public_record, items);
    ledger_b = initialize_evidence_ledger("ev-session-b", missing_prototype_case.public_record, items);
    assert ledger_a is not None;
    assert ledger_b is not None;
    if ledger_a is not None and ledger_b is not None {
        assert len(ledger_a.available_ids) == 7;
        assert len(ledger_a.discovered_ids) == 0;
        found = discover_evidence(ledger_a, "E-01", items);
        assert found.accepted;
        assert len(found.ledger.discovered_ids) == 1;
        assert len(ledger_b.discovered_ids) == 0;
    }
}

test "rejects duplicate and unknown discovery identifiers" {
    items = initial_evidence();
    ledger = initialize_evidence_ledger("ev-session-duplicates", missing_prototype_case.public_record, items);
    assert ledger is not None;
    if ledger is not None {
        first = discover_evidence(ledger, "E-02", items);
        assert first.accepted;
        duplicate = discover_evidence(first.ledger, "E-02", items);
        assert not duplicate.accepted;
        assert len(duplicate.ledger.discovered_ids) == 1;
        unknown = discover_evidence(first.ledger, "E-999", items);
        assert not unknown.accepted;
        blank = discover_evidence(first.ledger, " ", items);
        assert not blank.accepted;
    }
}

test "requires discovery before review and prevents duplicate reviews" {
    items = initial_evidence();
    ledger = initialize_evidence_ledger("ev-session-review", missing_prototype_case.public_record, items);
    assert ledger is not None;
    if ledger is not None {
        early = review_evidence(ledger, "E-03", items);
        assert not early.accepted;
        found = discover_evidence(ledger, "E-03", items);
        reviewed = review_evidence(found.ledger, "E-03", items);
        assert reviewed.accepted;
        assert "E-03" in reviewed_evidence_ids(reviewed.ledger);
        twice = review_evidence(reviewed.ledger, "E-03", items);
        assert not twice.accepted;
    }
}

test "connects only distinct discovered clues and deduplicates undirected links" {
    items = initial_evidence();
    ledger = initialize_evidence_ledger("ev-session-links", missing_prototype_case.public_record, items);
    assert ledger is not None;
    if ledger is not None {
        premature = connect_evidence(ledger, "E-01", "E-03", items);
        assert not premature.accepted;
        first = discover_evidence(ledger, "E-01", items);
        second = discover_evidence(first.ledger, "E-03", items);
        linked = connect_evidence(second.ledger, "E-01", "E-03", items);
        assert linked.accepted;
        assert len(evidence_connections(linked.ledger)) == 1;
        reverse = connect_evidence(linked.ledger, "E-03", "E-01", items);
        assert not reverse.accepted;
        self_link = connect_evidence(linked.ledger, "E-01", "E-01", items);
        assert not self_link.accepted;
        unknown = connect_evidence(linked.ledger, "E-01", "E-999", items);
        assert not unknown.accepted;
    }
}
