import ".styles.global.css";
import from services.caseManager { get_missing_prototype_briefing, get_missing_prototype_known_facts, start_missing_prototype_investigation, get_suspect_overview }
import from .components.CaseZeroLanding { CaseZeroLanding }
import from .components.CaseBriefingScreen { CaseBriefingScreen }
import from .components.SuspectOverviewScreen { SuspectOverviewScreen }
import from "@jac/runtime" { Router, Routes, Route }

def:pub app() -> JsxElement {
    return <Router><Routes>
        <Route path="/" element={<CaseZeroLanding />} />
        <Route path="/briefing" element={<CaseBriefingScreen />} />
        <Route path="/suspects/:session_id" element={<SuspectOverviewScreen />} />
    </Routes></Router>;
}
