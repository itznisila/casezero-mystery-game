import from .Panel { Panel }
sv import from ..services.gameApi { EvidenceItem, SuspectPublicProfile, Theory }

def:pub TheoryPanel(evidence: list[EvidenceItem], suspects: list[SuspectPublicProfile], theories: list[Theory], challenge: str, busy: bool, resolved: bool, onSubmit: any) -> JsxElement {
    has title: str = "";
    has summary: str = "";
    has suspect_id: str = "";
    has confidence: float = 0.6;
    has cited: list[str] = [];
    has local_error: str = "";

    def update_title(e: ChangeEvent) { title = e.target.value; }
    def update_summary(e: ChangeEvent) { summary = e.target.value; }
    def update_suspect(e: ChangeEvent) { suspect_id = e.target.value; }
    def set_confidence(value: float) { confidence = value; }
    def toggle(evidence_id: str) {
        if evidence_id in cited {
            cited = [x for x in cited if x != evidence_id];
        } else {
            cited = cited + [evidence_id];
        }
    }
    async def submit(e: MouseEvent) {
        if title.strip() == "" or summary.strip() == "" {
            local_error = "Give your theory a title and an explanation.";
            return;
        }
        local_error = "";
        ok = await onSubmit(title.strip(), summary.strip(), cited, suspect_id, confidence);
        if ok {
            title = "";
            summary = "";
            cited = [];
        }
    }

    return <div className="flex flex-col gap-5">
        <Panel title="Build a theory" subtitle="Link your reasoning to records you have secured. The Devil's Advocate will challenge it.">
            <label htmlFor="theory-title" className="block text-xs text-noir-muted">Title</label>
            <input id="theory-title" value={title} onChange={update_title} maxLength={120} placeholder="A route prepared in advance" disabled={resolved} className="mt-2 min-h-10 w-full border border-noir-line bg-noir px-3 text-sm text-noir-ink focus-visible:outline-2 focus-visible:outline-primary" />
            <label htmlFor="theory-summary" className="mt-3 block text-xs text-noir-muted">Explanation</label>
            <textarea id="theory-summary" value={summary} onChange={update_summary} maxLength={1000} rows={4} disabled={resolved} className="mt-2 w-full border border-noir-line bg-noir px-3 py-2 text-sm text-noir-ink focus-visible:outline-2 focus-visible:outline-primary" />
            <label htmlFor="theory-suspect" className="mt-3 block text-xs text-noir-muted">Who does it point to? (optional)</label>
            <select id="theory-suspect" value={suspect_id} onChange={update_suspect} disabled={resolved} className="mt-2 min-h-10 w-full border border-noir-line bg-noir px-3 text-sm text-noir-ink">
                <option value="">No one yet</option>
                {for person in suspects {<option key={person.id} value={person.id}>{person.name}</option>}}
            </select>
            <div role="group" aria-label="Confidence" className="mt-3 flex items-center gap-2">
                <span className="text-xs text-noir-muted">Confidence</span>
                <button type="button" aria-pressed={confidence == 0.3} onClick={lambda { set_confidence(0.3); }} className={"min-h-9 border px-3 text-xs " + ("border-primary text-primary" if confidence == 0.3 else "border-noir-line text-noir-muted")}>Low</button>
                <button type="button" aria-pressed={confidence == 0.6} onClick={lambda { set_confidence(0.6); }} className={"min-h-9 border px-3 text-xs " + ("border-primary text-primary" if confidence == 0.6 else "border-noir-line text-noir-muted")}>Medium</button>
                <button type="button" aria-pressed={confidence == 0.9} onClick={lambda { set_confidence(0.9); }} className={"min-h-9 border px-3 text-xs " + ("border-primary text-primary" if confidence == 0.9 else "border-noir-line text-noir-muted")}>High</button>
            </div>
            {len(evidence) > 0 and <fieldset className="mt-3 border border-noir-line p-3">
                <legend className="px-1 text-xs text-noir-muted">Records that support it</legend>
                <div className="flex flex-col gap-2">
                    {for item in evidence {<label key={item.id} className="flex items-center gap-2 text-xs text-noir-ink"><input type="checkbox" checked={item.id in cited} onChange={lambda { toggle(item.id); }} />{item.title}</label>}}
                </div>
            </fieldset>}
            {local_error != "" and <p role="alert" className="mt-3 text-sm text-red-200">{local_error}</p>}
            <button type="button" onClick={submit} disabled={busy or resolved} className="mt-4 min-h-11 border border-primary bg-primary px-6 font-semibold text-primary-foreground hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-60">Record theory</button>
        </Panel>
        {challenge != "" and <section className="border border-primary/40 bg-primary/5 p-4 sm:p-5">
            <p className="font-mono text-[10px] tracking-[0.16em] text-primary">DEVIL'S ADVOCATE</p>
            <p className="mt-2 text-sm leading-6 text-noir-ink">{challenge}</p>
        </section>}
        <Panel title="Recorded theories">
            {len(theories) == 0 and <p className="text-sm text-noir-muted">No theories recorded yet.</p>}
            <ul className="flex flex-col gap-3">
                {for item in theories {<li key={item.id} className="border border-noir-line bg-noir p-4">
                    <h3 className="font-medium text-noir-ink">{item.title}</h3>
                    <p className="mt-2 text-sm leading-6 text-noir-muted">{item.summary}</p>
                    <p className="mt-2 font-mono text-[10px] tracking-[0.12em] text-noir-muted">CONFIDENCE {"LOW" if item.confidence < 0.45 else ("MEDIUM" if item.confidence < 0.75 else "HIGH")}{len(item.evidence_ids) > 0 and <span> · CITES {", ".join(item.evidence_ids)}</span>}</p>
                </li>}}
            </ul>
        </Panel>
    </div>;
}
