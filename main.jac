import ".styles.global.css";
import from .components.CaseZeroLanding { CaseZeroLanding }
import from .components.CaseBriefingScreen { CaseBriefingScreen }
import from .components.SuspectOverviewScreen { SuspectOverviewScreen }
import from .components.EvidenceScreen { EvidenceScreen }
import from "@jac/runtime" { Router, Routes, Route }

def:pub app() -> JsxElement {
    return <Router><Routes>
        <Route path="/" element={<CaseZeroLanding />} />
        <Route path="/briefing" element={<CaseBriefingScreen />} />
        <Route path="/suspects/:session_id" element={<SuspectOverviewScreen />} />
        <Route path="/evidence/:session_id" element={<EvidenceScreen />} />
    </Routes></Router>;
}
