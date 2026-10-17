import ".styles.global.css";
import from .components.CaseZeroLanding { CaseZeroLanding }

def:pub app() -> JsxElement {
    return <CaseZeroLanding />;
}
