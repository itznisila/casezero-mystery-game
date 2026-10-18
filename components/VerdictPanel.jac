def:pub VerdictPanel(suspect_name: str, message: str, explanation: str, score: int, evidence_ids: list[str], busy: bool, onReplay: any) -> JsxElement {
    return <section className="border border-primary/50 bg-noir-raised p-5 sm:p-7" role="status" aria-live="polite">
        <p className="font-mono text-xs tracking-[0.18em] text-primary">CASE CLOSED · OFFICIAL RESULT</p>
        <h2 className="mt-3 font-serif text-3xl text-noir-ink sm:text-4xl">{message}</h2>
        <p className="mt-2 text-sm text-noir-muted">Responsible: <span className="text-noir-ink">{suspect_name}</span> · Score {str(score)}/100</p>
        <p className="mt-5 text-sm leading-7 text-noir-ink sm:text-base">{explanation}</p>
        {len(evidence_ids) > 0 and <p className="mt-4 font-mono text-[10px] tracking-[0.14em] text-noir-muted">RECORDS CITED · {", ".join(evidence_ids)}</p>}
        <button type="button" onClick={onReplay} disabled={busy} className="mt-6 min-h-12 border border-primary bg-primary px-7 font-semibold text-primary-foreground hover:bg-primary/90 disabled:opacity-60">Open a new investigation</button>
    </section>;
}
