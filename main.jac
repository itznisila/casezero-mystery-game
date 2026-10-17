import ".styles.global.css";
import from services.caseManager { get_missing_prototype_briefing, get_missing_prototype_known_facts, start_missing_prototype_investigation }
import from .components.CaseZeroLanding { CaseZeroLanding }
import from .components.CaseBriefingScreen { CaseBriefingScreen }
import from "@jac/runtime" { Router, Routes, Route }

def:pub app() -> JsxElement {
    return <Router><Routes>
        <Route path="/" element={<CaseZeroLanding />} />
        <Route path="/briefing" element={<CaseBriefingScreen />} />
    </Routes></Router>;
}
