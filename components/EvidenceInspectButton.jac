sv import from ..services.caseManager { discover_session_evidence_api }

def:pub EvidenceInspectButton(session_id: str, evidence_id: str, on_discovered: Callable[[], None]) -> JsxElement {
    async def inspect(e: MouseEvent) {
        accepted = await discover_session_evidence_api(session_id, evidence_id);
        if accepted { on_discovered(); }
    }
    return <button type="button" onClick={inspect} className="min-h-11 border border-primary bg-primary px-5 text-sm font-semibold text-primary-foreground">Inspect lead</button>;
}
