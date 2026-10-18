import from .Panel { Panel }
sv import from ..services.gameApi { SuspectPublicProfile, TranscriptLine, EvidenceItem }

def:pub InterviewPanel(suspects: list[SuspectPublicProfile], transcript: list[TranscriptLine], evidence: list[EvidenceItem], busy: bool, resolved: bool, onAsk: any) -> JsxElement {
    has selected: str = "";
    has question: str = "";
    has presented: list[str] = [];

    quick = [
        "Where were you during the incident?",
        "Tell me about the archive.",
        "What do you know about the freight lift?",
        "Did you have a reason to want Helix gone?",
        "What can you say about the others?"
    ];
    active = selected;
    if active == "" and len(suspects) > 0 { active = suspects[0].id; }
    lines = [line for line in transcript if line.suspect_id == active];

    def update_question(e: ChangeEvent) { question = e.target.value; }
    def pick_question(text: str) { question = text; }
    def pick_suspect(suspect_id: str) { selected = suspect_id; presented = []; }
    def toggle(evidence_id: str) {
        if evidence_id in presented {
            presented = [x for x in presented if x != evidence_id];
        } else {
            presented = presented + [evidence_id];
        }
    }
    def name_of(suspect_id: str) -> str {
        for person in suspects {
            if person.id == suspect_id { return person.name; }
        }
        return suspect_id;
    }
    async def submit(e: MouseEvent) {
        if question.strip() == "" or active == "" { return; }
        ok = await onAsk(active, question.strip(), presented);
        if ok {
            question = "";
            presented = [];
        }
    }

    return <Panel title="Interview room" subtitle="Questions are answered from each person's fixed account. Present secured evidence to test it.">
        <div role="group" aria-label="Choose a suspect" className="flex flex-wrap gap-2">
            {for person in suspects {<button key={person.id} type="button" aria-pressed={person.id == active} onClick={lambda { pick_suspect(person.id); }} className={"min-h-10 border px-3 text-sm focus-visible:outline-2 focus-visible:outline-primary " + ("border-primary text-primary" if person.id == active else "border-noir-line text-noir-ink hover:border-primary")}>{person.name}<span className="ml-2 font-mono text-[9px] text-noir-muted">{"HEARD" if person.interview_started else "NEW"}</span></button>}}
        </div>

        <div className="mt-4 flex max-h-96 flex-col gap-3 overflow-y-auto border border-noir-line bg-noir p-4" aria-live="polite">
            {len(lines) == 0 and <p className="text-sm leading-6 text-noir-muted">No questions asked of {name_of(active)} yet. Pick a prompt below or write your own.</p>}
            {for line in lines {<div key={line.id} className={"max-w-[92%] border p-3 text-sm leading-6 " + ("self-end border-primary/40 bg-primary/10 text-noir-ink" if line.speaker == "investigator" else "self-start border-noir-line bg-noir-raised text-noir-ink")}>
                <p className="font-mono text-[9px] tracking-[0.14em] text-noir-muted">{"YOU" if line.speaker == "investigator" else name_of(line.suspect_id).upper()}{line.speaker != "investigator" and line.mode != "rules-only" and <span className="ml-2 text-primary">AI-PHRASED</span>}</p>
                <p className="mt-1">{line.text}</p>
                {len(line.evidence_ids) > 0 and <p className="mt-2 font-mono text-[9px] tracking-[0.12em] text-primary/80">PRESENTED · {", ".join(line.evidence_ids)}</p>}
            </div>}}
        </div>

        <div className="mt-4 flex flex-wrap gap-2">
            {for text in quick {<button key={text} type="button" onClick={lambda { pick_question(text); }} className="border border-noir-line px-3 py-2 text-left text-xs text-noir-muted hover:border-primary hover:text-noir-ink">{text}</button>}}
        </div>

        <label htmlFor="interview-question" className="mt-4 block text-xs text-noir-muted">Your question</label>
        <textarea id="interview-question" value={question} onChange={update_question} maxLength={500} rows={3} disabled={resolved} placeholder="Ask something specific." className="mt-2 w-full border border-noir-line bg-noir px-3 py-2 text-sm text-noir-ink focus-visible:outline-2 focus-visible:outline-primary" />
        <p className="mt-1 text-right font-mono text-[10px] text-noir-muted">{str(len(question))}/500</p>

        {len(evidence) > 0 and <fieldset className="mt-3 border border-noir-line p-3">
            <legend className="px-1 text-xs text-noir-muted">Present evidence (optional)</legend>
            <div className="flex flex-col gap-2">
                {for item in evidence {<label key={item.id} className="flex items-center gap-2 text-xs text-noir-ink"><input type="checkbox" checked={item.id in presented} onChange={lambda { toggle(item.id); }} />{item.title}</label>}}
            </div>
        </fieldset>}
        {len(evidence) == 0 and <p className="mt-3 text-xs text-noir-muted">Secure evidence first if you want to confront someone with it.</p>}

        <button type="button" onClick={submit} disabled={busy or resolved or question.strip() == ""} className="mt-4 min-h-11 border border-primary bg-primary px-6 font-semibold text-primary-foreground hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-60">{"Asking…" if busy else "Ask " + name_of(active)}</button>
    </Panel>;
}
