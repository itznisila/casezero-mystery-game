import from services.caseService { CaseFile, Clue, Suspect, getCase, discoverClue, interviewSuspect, accuseSuspect }
import ".styles.global.css";
import from .components.CaseZeroInvestigation { CaseZeroInvestigation }

def:pub app() -> JsxElement {
    return <CaseZeroInvestigation />;
}
