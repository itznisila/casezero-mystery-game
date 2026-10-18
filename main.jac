import from services.caseManager {
    get_missing_prototype_briefing, start_missing_prototype_investigation,
    get_investigation_session, get_suspect_overview, reset_missing_prototype_investigation,
    InvestigationStartReceipt, PlayerCaseBriefing, SuspectPublicProfile
}
import from .components.CaseZeroLanding { CaseZeroLanding }
import from .components.CaseBriefingScreen { CaseBriefingScreen }
import from .components.SuspectOverviewScreen { SuspectOverviewScreen }
import from .components.CaseZeroInvestigation { CaseZeroInvestigation }
import ".styles.global.css";
import from "@jac/runtime" { Router, Routes, Route }


def:pub app() -> JsxElement {
    return <Router><Routes>
        <Route path="/" element={<CaseZeroLanding />} />
        <Route path="/briefing" element={<CaseBriefingScreen />} />
        <Route path="/suspects/:session_id" element={<SuspectOverviewScreen />} />
        <Route path="/evidence/:session_id" element={<CaseZeroInvestigation />} />
    </Routes></Router>;
}
