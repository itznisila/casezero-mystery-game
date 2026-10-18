import from lib.case_knowledge {
    Statement, STATEMENTS, CONTRADICTIONS, LEADS, TIMELINE_SEEDS, TOPIC_KEYWORDS,
    TOPIC_PRIORITY, GENERIC_LINES, OFFICIAL_EVENT_GATES, LOCATION_EVIDENCE
}
import from lib.missing_prototype_case { missing_prototype_case }

# Everything in this file is deterministic. No model is called here, so the same
# questions and evidence always produce the same answers, verdict inputs, and timeline.

obj InterviewOutcome {
    has statement_id: str;
    has topic: str;
    has line: str;
    has kind: str;
    has citations: list[str];
}

obj ContradictionFinding {
    has id: str;
    has title: str;
    has explanation: str;
    has significance: str;
    has statement_id: str;
    has against_id: str;
}

obj LeadStatus {
    has id: str;
    has title: str;
    has hint: str;
    has resolved: bool;
}

obj TimelineEntry {
    has id: str;
    has time: str;
    has text: str;
    has kind: str;
    has sources: list[str];
}

def _all_in(needed: list[str], pool: list[str]) -> bool {
    for item in needed {
        if not (item in pool) { return False; }
    }
    return True;
}

def _any_in(wanted: list[str], pool: list[str]) -> bool {
    for item in wanted {
        if item in pool { return True; }
    }
    return False;
}

def:pub statement_by_id(statement_id: str) -> Statement | None {
    for st in STATEMENTS {
        if st.id == statement_id { return st; }
    }
    return None;
}

def:pub classify_topic(suspect_id: str, question: str) -> str {
    text = question.lower();
    for mark in [",", ".", "?", "!", ";", "'", "\""] {
        text = text.replace(mark, " ");
    }
    text = " " + text + " ";
    for topic in TOPIC_PRIORITY {
        words = TOPIC_KEYWORDS[topic];
        for word in words {
            if word in text { return topic; }
        }
        if topic == "others" {
            for name in ["mara", "eli", "june"] {
                if name != suspect_id and (" " + name + " ") in text { return "others"; }
            }
        }
    }
    return "general";
}

def:pub resolve_statement(suspect_id: str, topic: str, presented: list[str]) -> Statement | None {
    best: Statement | None = None;
    best_size = -1;
    for st in STATEMENTS {
        if st.suspect_id != suspect_id or st.topic != topic { continue; }
        if not _all_in(st.presents, presented) { continue; }
        if len(st.presents) > best_size {
            best = st;
            best_size = len(st.presents);
        }
    }
    if best is not None and best_size > 0 { return best; }
    if len(presented) > 0 {
        reaction: Statement | None = None;
        reaction_size = 0;
        for st in STATEMENTS {
            if st.suspect_id != suspect_id or len(st.presents) == 0 { continue; }
            if not _all_in(st.presents, presented) { continue; }
            if len(st.presents) > reaction_size {
                reaction = st;
                reaction_size = len(st.presents);
            }
        }
        if reaction is not None { return reaction; }
    }
    return best;
}

def:pub run_interview(suspect_id: str, question: str, presented: list[str]) -> InterviewOutcome {
    topic = classify_topic(suspect_id, question);
    chosen = resolve_statement(suspect_id, topic, presented);
    if chosen is None {
        line = "That person is not a suspect in this case.";
        if suspect_id in GENERIC_LINES { line = GENERIC_LINES[suspect_id]; }
        return InterviewOutcome(statement_id="", topic=topic, line=line, kind="deflection", citations=presented);
    }
    return InterviewOutcome(statement_id=chosen.id, topic=chosen.topic, line=chosen.line, kind=chosen.kind, citations=presented + [chosen.id]);
}

def:pub find_contradictions(discovered: list[str], revealed: list[str]) -> list[ContradictionFinding] {
    known = discovered + revealed;
    found: list[ContradictionFinding] = [];
    for c in CONTRADICTIONS {
        if c.statement_id in revealed and c.against_id in known {
            found.append(ContradictionFinding(id=c.id, title=c.title, explanation=c.explanation, significance=c.significance, statement_id=c.statement_id, against_id=c.against_id));
        }
    }
    return found;
}

def:pub get_lead_statuses(discovered: list[str], revealed: list[str], found_ids: list[str]) -> list[LeadStatus] {
    known = discovered + revealed + found_ids;
    out: list[LeadStatus] = [];
    for lead in LEADS {
        visible = len(lead.visible_when_any) == 0 or _any_in(lead.visible_when_any, known);
        if not visible { continue; }
        resolved = len(lead.resolved_when_all) > 0 and _all_in(lead.resolved_when_all, known);
        out.append(LeadStatus(id=lead.id, title=lead.title, hint=lead.hint, resolved=resolved));
    }
    return out;
}

def _sorted_entries(entries: list[TimelineEntry]) -> list[TimelineEntry] {
    result: list[TimelineEntry] = [];
    for entry in entries {
        position = len(result);
        for index in range(len(result)) {
            if entry.time < result[index].time {
                position = index;
                break;
            }
        }
        result.insert(position, entry);
    }
    return result;
}

def:pub build_timeline(discovered: list[str], revealed: list[str]) -> list[TimelineEntry] {
    known = discovered + revealed;
    entries: list[TimelineEntry] = [];
    for event in missing_prototype_case.public_record.timeline {
        needs = event.evidence_ids;
        if len(needs) == 0 and event.id in OFFICIAL_EVENT_GATES { needs = OFFICIAL_EVENT_GATES[event.id]; }
        if not _all_in(needs, known) { continue; }
        kind = "record";
        if event.id in OFFICIAL_EVENT_GATES { kind = "claim"; }
        entries.append(TimelineEntry(id=event.id, time=event.occurred_at, text=event.description, kind=kind, sources=needs));
    }
    for seed in TIMELINE_SEEDS {
        if _all_in(seed.needs_all, revealed) {
            entries.append(TimelineEntry(id=seed.id, time=seed.time, text=seed.text, kind=seed.kind, sources=seed.needs_all));
        }
    }
    return _sorted_entries(entries);
}

def:pub suspects_with_statements(revealed: list[str]) -> list[str] {
    people: list[str] = [];
    for st in STATEMENTS {
        if st.id in revealed and not (st.suspect_id in people) { people.append(st.suspect_id); }
    }
    return people;
}

def:pub all_evidence_ids() -> list[str] {
    ids: list[str] = [];
    for loc_id in LOCATION_EVIDENCE {
        for ev in LOCATION_EVIDENCE[loc_id] { ids.append(ev); }
    }
    return ids;
}

# Progress is a simple milestone count: records secured, suspects heard, key
# contradictions logged, and leads resolved. It never reveals who is guilty.
def:pub compute_progress(discovered: list[str], revealed: list[str], findings: list[ContradictionFinding], leads: list[LeadStatus]) -> int {
    evidence_ids = all_evidence_ids();
    key_total = 0;
    for c in CONTRADICTIONS {
        if c.significance == "key" { key_total = key_total + 1; }
    }
    key_found = 0;
    for f in findings {
        if f.significance == "key" { key_found = key_found + 1; }
    }
    secured = 0;
    for ev in evidence_ids {
        if ev in discovered { secured = secured + 1; }
    }
    resolved = 0;
    for lead in leads {
        if lead.resolved { resolved = resolved + 1; }
    }
    suspect_total = len(missing_prototype_case.public_record.suspects);
    total = len(evidence_ids) + suspect_total + key_total + len(LEADS);
    done = secured + len(suspects_with_statements(revealed)) + key_found + resolved;
    if total == 0 { return 0; }
    return int(done * 100 / total);
}
