import from .Panel { Panel }
sv import from ..services.gameApi { EvidenceItem, SuspectPublicProfile }

def:pub AccusationPanel(suspects: list[SuspectPublicProfile], evidence: list[EvidenceItem], busy: bool, resolved: bool, onAccuse: any) -> JsxElement {
    has suspect_id: str = "";
    has explanation: str = "";
    has cited: list[str] = [];
    has confirming: bool = False;
    has local_error: str = "";

    def update_suspect(e: ChangeEvent) { suspect_id = e.target.value; confirming = False; }
    def update_explanation(e: ChangeEvent) { explanation = e.target.value; confirming = False; }
    def toggle(evidence_id: str) {
        confirming = False;
        if evidence_id in cited {
            cited = [x for x in cited if x != evidence_id];
        } else {
            cited = cited + [evidence_id];
        }
    }
    def name_of(who: str) -> str {
        for person in suspects {
            if person.id == who { return person.name; }
        }
        return who;
    }
    def review(e: MouseEvent) {
        if suspect_id == "" or explanation.strip() == "" or len(cited) == 0 {
            local_error = "Choose a suspect, explain your reasoning, and cite at least one secured record.";
            return;
        }
        local_error = "";
        confirming = True;
    }
    async def confirm(e: MouseEvent) {
        ok = await onAccuse(suspect_id, explanation.strip(), cited);
        confirming = False;
        if ok { explanation = ""; }
    }

    return <Panel title="Final accusation" subtitle="Name one person and cite the records that prove it. The case engine alone decides the outcome. A wrong accusation keeps the case open.">
        <label htmlFor="accused-suspect" className="block text-xs text-noir-muted">Who is responsible?</label>
        <select id="accused-suspect" value={suspect_id} onChange={update_suspect} disabled={resolved} className="mt-2 min-h-11 w-full border border-noir-line bg-noir px-3 text-sm text-noir-ink">
            <option value="">Choose a suspect</option>
            {for person in suspects {<option key={person.id} value={person.id}>{person.name} · {person.role}</option>}}
        </select>
        <label htmlFor="accusation-explanation" className="mt-3 block text-xs text-noir-muted">Your reasoning</label>
        <textarea id="accusation-explanation" value={explanation} onChange={update_explanation} maxLength={1000} rows={5} disabled={resolved} placeholder="Explain how the records show who did it." className="mt-2 w-full border border-noir-line bg-noir px-3 py-2 text-sm text-noir-ink focus-visible:outline-2 focus-visible:outline-primary" />
        {len(evidence) == 0 and <p className="mt-3 text-xs text-noir-muted">You have no secured records yet. The case engine requires the two system logs about the credential and the lift before it will hear an accusation.</p>}
        {len(evidence) > 0 and <fieldset className="mt-3 border border-noir-line p-3">
            <legend className="px-1 text-xs text-noir-muted">Cite your records</legend>
            <div className="flex flex-col gap-2">
                {for item in evidence {<label key={item.id} className="flex items-center gap-2 text-xs text-noir-ink"><input type="checkbox" checked={item.id in cited} onChange={lambda { toggle(item.id); }} />{item.title}</label>}}
            </div>
        </fieldset>}
        {local_error != "" and <p role="alert" className="mt-3 text-sm text-red-200">{local_error}</p>}
        {not confirming and <button type="button" onClick={review} disabled={busy or resolved} className="mt-4 min-h-11 border border-primary px-6 font-semibold text-primary hover:bg-primary hover:text-primary-foreground disabled:cursor-not-allowed disabled:opacity-60">Review accusation</button>}
        {confirming and <div className="mt-4 border border-primary/50 bg-primary/5 p-4" role="alertdialog" aria-label="Confirm accusation">
            <p className="text-sm leading-6 text-noir-ink">You are about to accuse <strong>{name_of(suspect_id)}</strong> citing {str(len(cited))} record{"" if len(cited) == 1 else "s"}. This is your formal accusation.</p>
            <div className="mt-3 flex flex-wrap gap-3">
                <button type="button" onClick={confirm} disabled={busy} className="min-h-11 border border-primary bg-primary px-6 font-semibold text-primary-foreground hover:bg-primary/90 disabled:opacity-60">{"Filing…" if busy else "Confirm accusation"}</button>
                <button type="button" onClick={lambda { confirming = False; }} disabled={busy} className="min-h-11 border border-noir-line px-5 text-sm text-noir-ink hover:border-primary">Go back</button>
            </div>
        </div>}
    </Panel>;
}
