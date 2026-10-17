import from lib.casezero_domain { EvidenceItem, CaseRecord }
import from lib.missing_prototype_case { missing_prototype_case }

obj EvidenceLink {
    has first_id: str;
    has second_id: str;
}

obj EvidenceLedger {
    has session_id: str;
    has available_ids: list[str];
    has discovered_ids: list[str] = [];
    has reviewed_ids: list[str] = [];
    has connections: list[EvidenceLink] = [];
}

obj EvidenceOperation {
    has accepted: bool;
    has message: str;
    has ledger: EvidenceLedger;
}

# Seed only official, pre-authored evidence. Suspect statements are evidence records,
# but their disputed alibis are not treated as established facts.
glob INITIAL_EVIDENCE: list[EvidenceItem] = [
    EvidenceItem(id="E-01", title="Archive access record", summary="A director credential opened the prototype archive at 21:14.", detail="The access system records Mara Voss's director badge opening the archive at 21:14, contradicting her stated location in the east laboratory.", discovered_at="21:14", suspect_id="mara"),
    EvidenceItem(id="E-02", title="Cryogenic residue", summary="A trace from the Helix transport case was found in the freight lift.", detail="The residue is consistent with the prototype's cryogenic transport case and places the case in the freight lift after it left the archive.", discovered_at="21:20", suspect_id="mara"),
    EvidenceItem(id="E-03", title="Freight-lift maintenance record", summary="The service lift was put into manual mode using director credentials.", detail="A 21:08 request from the archive terminal used Mara Voss's director credential to enable manual mode on the freight lift.", discovered_at="21:08", suspect_id="mara"),
    EvidenceItem(id="E-04", title="Loading corridor camera still", summary="A lab-coated figure carried a silver case toward the loading bay.", detail="A reflection at 21:22 shows an unidentified lab-coated figure moving a silver case toward the loading bay; the image does not identify the carrier.", discovered_at="21:22", suspect_id=None),
    EvidenceItem(id="S-MARA-01", title="Mara's east-laboratory statement", summary="Mara says she reviewed samples in the east laboratory from 21:00 to 21:30.", detail="This is a recorded suspect statement, not independently verified fact. The 21:14 archive access record conflicts with the account.", discovered_at="21:00", suspect_id="mara"),
    EvidenceItem(id="S-ELI-01", title="Eli's security-desk statement", summary="Eli says he remained at the security desk throughout the incident.", detail="This is a recorded suspect statement. His monitoring role gives him camera access, but there is no record linking him to the director credential used for the archive and lift override.", discovered_at="21:00", suspect_id="eli"),
    EvidenceItem(id="S-JUNE-01", title="June's west-laboratory statement", summary="June says she prepared a report in the west laboratory during the incident.", detail="This is a recorded suspect statement. Her patent dispute is a possible motive, but there is no evidence linking her to the archive access or freight-lift override.", discovered_at="21:00", suspect_id="june")
];

def:pub initial_evidence() -> list[EvidenceItem] {
    return INITIAL_EVIDENCE;
}

def:pub is_valid_evidence_registry(items: list[EvidenceItem]) -> bool {
    if len(items) == 0 { return False; }
    ids = [item.id for item in items];
    if len(set(ids)) != len(ids) { return False; }
    for item in items {
        if not item.is_valid() or item.detail.strip() == "" { return False; }
    }
    return True;
}

def:pub initialize_evidence_ledger(session_id: str, case_record: CaseRecord, items: list[EvidenceItem]) -> EvidenceLedger | None {
    if session_id.strip() == "" or not case_record.is_valid() or not is_valid_evidence_registry(items) { return None; }
    registry_ids = [item.id for item in items];
    suspect_ids = [suspect.id for suspect in case_record.suspects];
    for case_item in case_record.evidence {
        if not (case_item.id in registry_ids) { return None; }
    }
    for item in items {
        if item.suspect_id is not None and not (item.suspect_id in suspect_ids) { return None; }
    }
    return EvidenceLedger(session_id=session_id, available_ids=registry_ids);
}

def _known_evidence(evidence_id: str, items: list[EvidenceItem]) -> bool {
    for item in items {
        if item.id == evidence_id { return True; }
    }
    return False;
}

def:pub discover_evidence(ledger: EvidenceLedger, evidence_id: str, items: list[EvidenceItem]) -> EvidenceOperation {
    if evidence_id.strip() == "" or not _known_evidence(evidence_id, items) or not (evidence_id in ledger.available_ids) {
        return EvidenceOperation(accepted=False, message="Unknown or unavailable evidence identifier.", ledger=ledger);
    }
    if evidence_id in ledger.discovered_ids {
        return EvidenceOperation(accepted=False, message="Evidence has already been discovered.", ledger=ledger);
    }
    next_ledger = EvidenceLedger(session_id=ledger.session_id, available_ids=ledger.available_ids, discovered_ids=ledger.discovered_ids + [evidence_id], reviewed_ids=ledger.reviewed_ids, connections=ledger.connections);
    return EvidenceOperation(accepted=True, message="Evidence discovered.", ledger=next_ledger);
}

def:pub review_evidence(ledger: EvidenceLedger, evidence_id: str, items: list[EvidenceItem]) -> EvidenceOperation {
    if evidence_id.strip() == "" or not _known_evidence(evidence_id, items) or not (evidence_id in ledger.available_ids) {
        return EvidenceOperation(accepted=False, message="Unknown or unavailable evidence identifier.", ledger=ledger);
    }
    if not (evidence_id in ledger.discovered_ids) { return EvidenceOperation(accepted=False, message="Discover evidence before reviewing it.", ledger=ledger); }
    if evidence_id in ledger.reviewed_ids { return EvidenceOperation(accepted=False, message="Evidence has already been reviewed.", ledger=ledger); }
    next_ledger = EvidenceLedger(session_id=ledger.session_id, available_ids=ledger.available_ids, discovered_ids=ledger.discovered_ids, reviewed_ids=ledger.reviewed_ids + [evidence_id], connections=ledger.connections);
    return EvidenceOperation(accepted=True, message="Evidence reviewed.", ledger=next_ledger);
}

def:pub connect_evidence(ledger: EvidenceLedger, first_id: str, second_id: str, items: list[EvidenceItem]) -> EvidenceOperation {
    if first_id.strip() == "" or second_id.strip() == "" or not _known_evidence(first_id, items) or not _known_evidence(second_id, items) or not (first_id in ledger.available_ids) or not (second_id in ledger.available_ids) {
        return EvidenceOperation(accepted=False, message="Unknown or unavailable evidence identifier.", ledger=ledger);
    }
    if first_id == second_id { return EvidenceOperation(accepted=False, message="Choose two different evidence items.", ledger=ledger); }
    if not (first_id in ledger.discovered_ids) or not (second_id in ledger.discovered_ids) { return EvidenceOperation(accepted=False, message="Discover both evidence items before connecting them.", ledger=ledger); }
    for link in ledger.connections {
        if (link.first_id == first_id and link.second_id == second_id) or (link.first_id == second_id and link.second_id == first_id) {
            return EvidenceOperation(accepted=False, message="These evidence items are already connected.", ledger=ledger);
        }
    }
    next_ledger = EvidenceLedger(session_id=ledger.session_id, available_ids=ledger.available_ids, discovered_ids=ledger.discovered_ids, reviewed_ids=ledger.reviewed_ids, connections=ledger.connections + [EvidenceLink(first_id=first_id, second_id=second_id)]);
    return EvidenceOperation(accepted=True, message="Evidence connected.", ledger=next_ledger);
}

def:pub available_evidence(ledger: EvidenceLedger, items: list[EvidenceItem]) -> list[EvidenceItem] {
    return [item for item in items if item.id in ledger.available_ids];
}

def:pub discovered_evidence(ledger: EvidenceLedger, items: list[EvidenceItem]) -> list[EvidenceItem] {
    return [item for item in items if item.id in ledger.discovered_ids];
}

def:pub reviewed_evidence_ids(ledger: EvidenceLedger) -> list[str] {
    return ledger.reviewed_ids;
}

def:pub evidence_connections(ledger: EvidenceLedger) -> list[EvidenceLink] {
    return ledger.connections;
}
