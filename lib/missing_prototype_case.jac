import from .casezero_domain { CaseRecord, Suspect, EvidenceItem, TimelineEvent }

obj CaseLocation {
    has id: str;
    has name: str;
    has description: str;

    def is_valid() -> bool {
        return self.id.strip() != "" and self.name.strip() != "" and self.description.strip() != "";
    }
}

obj PlayerCaseIntroduction {
    has case_id: str;
    has title: str;
    has introduction: str;
    has briefing: str;
    has initial_objectives: list[str];
    has locations: list[CaseLocation];
    has public_record: CaseRecord;

    def is_valid() -> bool {
        return self.case_id.strip() != "" and self.title.strip() != "" and self.introduction.strip() != "" and self.briefing.strip() != "" and len(self.initial_objectives) > 0 and len(self.locations) > 0 and self.public_record.is_valid();
    }
}

obj CanonicalCaseSolution {
    has case_id: str;
    has culprit_id: str;
    has explanation: str;
    has supporting_evidence_ids: list[str];

    def is_valid() -> bool {
        return self.case_id.strip() != "" and self.culprit_id.strip() != "" and self.explanation.strip() != "" and len(self.supporting_evidence_ids) > 0;
    }
}

obj MissingPrototypeCaseData {
    has player_case: PlayerCaseIntroduction;
    has hidden_solution: CanonicalCaseSolution;

    def is_valid() -> bool {
        if not self.player_case.is_valid() or not self.hidden_solution.is_valid() { return False; }
        if self.player_case.case_id != self.hidden_solution.case_id { return False; }
        if len(self.player_case.public_record.suspects) != 3 { return False; }
        if not (self.hidden_solution.culprit_id in [suspect.id for suspect in self.player_case.public_record.suspects]) { return False; }
        return True;
    }
}

# Only these fields are intended for the initial player-facing case introduction.
glob missing_prototype_case: PlayerCaseIntroduction = PlayerCaseIntroduction(
    case_id="case-001",
    title="The Missing Prototype",
    introduction="A research prototype has disappeared from a secured facility. The archive was locked, the alarm log shows no breach, and three staff members had both reason and opportunity to be near the research wing.",
    briefing="At 21:30, the Helix energy-storage prototype was reported missing from the Northstar Research Facility's sealed archive. Investigators found no forced entry. Establish how the prototype left the building, test each account against the official timeline, and identify who used authorized access to remove it.",
    initial_objectives=[
        "Inspect the archive access record and facility maintenance log.",
        "Establish where each staff member was between 21:00 and 21:30.",
        "Trace the prototype's route from the sealed archive to an exit."
    ],
    locations=[
        CaseLocation(id="archive", name="Prototype Archive", description="A badge-controlled room in the Northstar Research Facility's research wing. The prototype was stored here in a sealed transport case."),
        CaseLocation(id="east-lab", name="East Laboratory", description="The sample-review area where Mara Voss says she worked during the incident."),
        CaseLocation(id="security-desk", name="Security Desk", description="The staffed monitoring point where Eli Navarro says he remained on duty."),
        CaseLocation(id="west-lab", name="West Laboratory", description="The materials workspace where June Park says she prepared a report."),
        CaseLocation(id="freight-lift", name="Freight Lift", description="A service lift connecting the research wing to the loading corridor."),
        CaseLocation(id="loading-bay", name="Loading Bay", description="A controlled service exit monitored by a corridor camera.")
    ],
    public_record=CaseRecord(
        id="case-001",
        title="The Missing Prototype",
        briefing="The Helix prototype vanished from a secured archive at 21:30. The facility registered no forced entry.",
        objective="Determine how the prototype left the facility and which account is contradicted by the records.",
        suspects=[
            Suspect(id="mara", name="Mara Voss", role="Research director", profile="Exacting and protective of her team's work, Mara built her career overseeing the Helix program. She has managed the Northstar research division for eight years and knows its access procedures.", motive="The delayed prototype launch put her division's renewal funding and her promised promotion at risk.", alibi="Says she reviewed samples in the east laboratory from 21:00 to 21:30.", opportunity="Her director badge can enter the archive and authorize service access to the freight lift."),
            Suspect(id="eli", name="Eli Navarro", role="Security engineer", profile="Methodical and cautious, Eli designed the facility's access-monitoring system and has worked at Northstar for five years. A recent audit found gaps in his shift documentation.", motive="He resents being blamed for the audit findings and feared dismissal if another security incident occurred.", alibi="Says he remained at the security desk monitoring the facility throughout the incident.", opportunity="His security role gives him access to monitoring records and the loading-corridor camera system, but not director-level archive privileges."),
            Suspect(id="june", name="Dr. June Park", role="Materials scientist", profile="A candid specialist in cryogenic materials, June joined the Helix team three years ago. She is preparing an independent patent application related to the prototype's casing.", motive="A patent dispute could delay her own work and weaken her negotiating position with Northstar.", alibi="Says she prepared a materials report in the west laboratory during the incident.", opportunity="Her laboratory clearance permits entry to the research wing, but she cannot authorize the freight-lift override." )
        ],
        evidence=[
            EvidenceItem(id="E-01", title="Archive access log", summary="A director badge opened the prototype archive at 21:14.", detail="The badge log records Mara Voss's director credential entering the archive at 21:14, contradicting her statement that she remained in the east laboratory.", discovered_at="21:14", suspect_id="mara"),
            EvidenceItem(id="E-02", title="Cryogenic residue", summary="A transport-case residue trail was found in the freight lift.", detail="Residue consistent with the Helix transport case remained on the freight-lift floor after the case passed through.", discovered_at="21:20", suspect_id="mara"),
            EvidenceItem(id="E-03", title="Freight-lift maintenance log", summary="The lift was switched to manual mode using director credentials.", detail="At 21:08, a request from the archive terminal used Mara's director credential to switch the freight lift to manual mode.", discovered_at="21:08", suspect_id="mara"),
            EvidenceItem(id="E-04", title="Loading-corridor camera still", summary="A covered figure carried a silver case toward the loading bay.", detail="A reflection at 21:22 shows a lab-coated figure carrying a silver case toward the loading bay. The image alone cannot identify the person.", discovered_at="21:22", suspect_id=None)
        ],
        timeline=[
            TimelineEvent(id="T-01", occurred_at="21:00", description="Mara later says she began reviewing samples in the east laboratory."),
            TimelineEvent(id="T-02", occurred_at="21:08", description="The freight lift was switched to manual mode from the archive terminal using director credentials.", evidence_ids=["E-03"], suspect_id="mara"),
            TimelineEvent(id="T-03", occurred_at="21:14", description="Mara's director badge opened the prototype archive.", evidence_ids=["E-01"], suspect_id="mara"),
            TimelineEvent(id="T-04", occurred_at="21:20", description="Cryogenic residue consistent with the prototype's transport case was found in the freight lift.", evidence_ids=["E-02"], suspect_id="mara"),
            TimelineEvent(id="T-05", occurred_at="21:22", description="A camera reflection captured a lab-coated figure carrying a silver case toward the loading bay.", evidence_ids=["E-04"]),
            TimelineEvent(id="T-06", occurred_at="21:30", description="The missing prototype was reported to facility security.")
        ]
    )
);

# Keep the canonical culprit and full explanation separate from the initial player record.
glob missing_prototype_canonical_solution: CanonicalCaseSolution = CanonicalCaseSolution(
    case_id="case-001",
    culprit_id="mara",
    explanation="Mara used her director credential at 21:08 to put the freight lift into manual mode, then entered the archive at 21:14 and removed the Helix prototype in its silver cryogenic transport case. She routed it through the freight lift and toward the loading bay. Her east-laboratory alibi is contradicted by the badge record; the maintenance log, residue, and camera still corroborate the route. Eli's monitoring access does not provide director archive authorization, and June's patent dispute supplies motive but no evidence linking her to the lift override or archive entry.",
    supporting_evidence_ids=["E-01", "E-02", "E-03", "E-04"]
);

glob missing_prototype_case_data: MissingPrototypeCaseData = MissingPrototypeCaseData(
    player_case=missing_prototype_case,
    hidden_solution=missing_prototype_canonical_solution
);

def:pub is_valid_missing_prototype_case() -> bool {
    if not missing_prototype_case_data.is_valid() { return False; }
    if len(missing_prototype_case.locations) != 6 { return False; }
    suspect_ids = [suspect.id for suspect in missing_prototype_case.public_record.suspects];
    if len(set(suspect_ids)) != 3 { return False; }
    for suspect in missing_prototype_case.public_record.suspects {
        if not suspect.is_valid() or suspect.profile.strip() == "" or suspect.motive.strip() == "" or suspect.alibi.strip() == "" or suspect.opportunity.strip() == "" { return False; }
    }
    for item in missing_prototype_case.public_record.evidence {
        if not item.is_valid() { return False; }
    }
    for event in missing_prototype_case.public_record.timeline {
        if not event.is_valid() { return False; }
        for evidence_id in event.evidence_ids {
            if not (evidence_id in [item.id for item in missing_prototype_case.public_record.evidence]) { return False; }
        }
    }
    return missing_prototype_canonical_solution.culprit_id == "mara";
}
