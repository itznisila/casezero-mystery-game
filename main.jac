import from services.caseManager {
    get_missing_prototype_briefing, start_missing_prototype_investigation,
    get_investigation_session, get_suspect_overview, reset_missing_prototype_investigation,
    InvestigationStartReceipt, PlayerCaseBriefing, SuspectPublicProfile
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