enum InvestigationActionKind: str {
    INSPECT = "inspect",
    INTERVIEW = "interview",
    FORM_THEORY = "form_theory",
    ACCUSE = "accuse"
}

obj Suspect {
    has id: str;
    has name: str;
    has role: str;
    has profile: str;
    has motive: str;
    has alibi: str;

    def is_valid() -> bool {
        return self.id.strip() != "" and self.name.strip() != "" and self.role.strip() != "";
    }
}

obj EvidenceItem {
    has id: str;
    has title: str;
    has summary: str;
    has detail: str;
    has discovered_at: str;
    has suspect_id: str | None = None;

    def is_valid() -> bool {
        return self.id.strip() != "" and self.title.strip() != "" and self.summary.strip() != "";
    }
}

obj TimelineEvent {
    has id: str;
    has occurred_at: str;
    has description: str;
    has evidence_ids: list[str] = [];
    has suspect_id: str | None = None;

    def is_valid() -> bool {
        return self.id.strip() != "" and self.occurred_at.strip() != "" and self.description.strip() != "";
    }
}

obj InterviewMessage {
    has id: str;
    has suspect_id: str;
    has speaker: str;
    has content: str;
    has sent_at: str;
    has evidence_ids: list[str] = [];

    def is_valid() -> bool {
        return self.id.strip() != "" and self.suspect_id.strip() != "" and self.content.strip() != "";
    }
}

obj InvestigationAction {
    has id: str;
    has kind: InvestigationActionKind;
    has actor_id: str;
    has created_at: str;
    has target_id: str | None = None;
    has evidence_ids: list[str] = [];

    def is_valid() -> bool {
        return self.id.strip() != "" and self.actor_id.strip() != "" and self.created_at.strip() != "";
    }
}

obj Theory {
    has id: str;
    has title: str;
    has summary: str;
    has evidence_ids: list[str] = [];
    has suspect_ids: list[str] = [];
    has confidence: float = 0.0;

    def is_valid() -> bool {
        return self.id.strip() != "" and self.title.strip() != "" and self.confidence >= 0.0 and self.confidence <= 1.0;
    }
}

obj CaseRecord {
    has id: str;
    has title: str;
    has briefing: str;
    has objective: str;
    has suspects: list[Suspect] = [];
    has evidence: list[EvidenceItem] = [];
    has timeline: list[TimelineEvent] = [];

    def is_valid() -> bool {
        return self.id.strip() != "" and self.title.strip() != "" and self.briefing.strip() != "" and self.objective.strip() != "";
    }
}

obj AccusationResult {
    has valid: bool;
    has correct: bool;
    has message: str;
    has suspect_id: str | None = None;
    has explanation: str = "";
    has evidence_ids: list[str] = [];
    has score: int = 0;

    def is_valid() -> bool {
        return self.message.strip() != "" and self.score >= 0 and self.score <= 100;
    }
}
