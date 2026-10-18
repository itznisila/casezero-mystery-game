import from services.caseManager {
    get_investigation_session, get_investigation_dossier,
    submit_investigation_action, reset_missing_prototype_investigation,
    get_missing_prototype_briefing, start_missing_prototype_investigation,
    get_suspect_overview, get_session_evidence_api,
    InvestigationSession, InvestigationDossier, InvestigationCommand,
    InvestigationStartReceipt, PlayerCaseBriefing, SuspectPublicProfile, EvidenceCollection
}
import from services.caseAgents {
    interview_agent, evidence_analyst_agent, theory_coach_agent,
    verdict_explainer_agent, InterviewReply, AgentBrief, LeadPlan
}
import from services.gameApi {
    get_case_board, visit_location, secure_evidence, open_timeline, ask_suspect,
    ask_advisor, submit_theory, file_accusation, restart_investigation,
    CaseBoard, InterviewTurn, ActionResult, LocationView, LockedItem,
    RevealedStatement, TranscriptLine, AgentLogEntry
}
import from services.caseLogic { TimelineEntry, ContradictionFinding, LeadStatus }
import from services.advisors { list_advisors, AdvisorReply, AdvisorInfo }
import from .components.CaseZeroLanding { CaseZeroLanding }
import from .components.CaseBriefingScreen { CaseBriefingScreen }
import from .components.SuspectOverviewScreen { SuspectOverviewScreen }
import from .components.InvestigationRoom { InvestigationRoom }
import ".styles.global.css";
import from "@jac/runtime" { Router, Routes, Route }


def:pub app() -> JsxElement {
    return <Router><Routes>
        <Route path="/" element={<CaseZeroLanding />} />
        <Route path="/briefing" element={<CaseBriefingScreen />} />
        <Route path="/suspects/:session_id" element={<SuspectOverviewScreen />} />
        <Route path="/case/:session_id" element={<InvestigationRoom />} />
        <Route path="/evidence/:session_id" element={<InvestigationRoom />} />
    </Routes></Router>;
}
