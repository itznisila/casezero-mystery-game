import from lib.casezero_domain { CaseRecord, EvidenceItem, InvestigationAction, InvestigationActionKind, InterviewMessage, Theory, AccusationResult }
import from lib.missing_prototype_case { CaseLocation }

obj PlayerCaseBriefing {
    has case_id: str;
    has title: str;
    has introduction: str;
    has briefing: str;
    has known_facts: list[str];
    has objectives: list[str];
    has location_names: list[str];
    has location_ids: list[str];
    has timeline_event_ids: list[str];
    has suspect_ids: list[str];
}

obj InvestigationSession {
    has session_id: str;
    has case_id: str;
    has player_briefing: PlayerCaseBriefing;
    has case_record: CaseRecord;
    has discovered_evidence_ids: list[str] = [];
    has interviewed_suspect_ids: list[str] = [];
    has visited_location_ids: list[str] = [];
    has timeline_accessed: bool = False;
    has resolved: bool = False;
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

obj InvestigationStartReceipt {
    has session_id: str;
    has case_id: str;
    has status: str;
    has message: str;
}

obj SuspectPublicProfile {
    has id: str;
    has name: str;
    has role: str;
    has profile: str;
    has interview_started: bool;
}

obj EvidenceCollection {
    has discovered: list[EvidenceItem];
    has available_ids: list[str];
}
