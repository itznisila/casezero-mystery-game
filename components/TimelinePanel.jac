import from .Panel { Panel }
sv import from ..services.gameApi { TimelineEntry, ContradictionFinding, LeadStatus }

def:pub TimelinePanel(timeline_open: bool, timeline: list[TimelineEntry], contradictions: list[ContradictionFinding], leads: list[LeadStatus], busy: bool, resolved: bool, onOpen: any) -> JsxElement {
    def kind_class(kind: str) -> str {
        if kind == "record" { return "border-primary/60 text-primary"; }
        if kind == "corroborated" { return "border-emerald-300/50 text-emerald-200"; }
        return "border-noir-line text-noir-muted";
    }

    return <div className="flex flex-col gap-5">
        <Panel title="Official timeline" subtitle="Records appear as you secure them. Claims are what people say; they stay unverified until a record agrees.">
            {not timeline_open and <div className="border border-dashed border-noir-line p-5">
                <p className="text-sm leading-6 text-noir-muted">The official timeline has not been opened.</p>
                <button type="button" onClick={onOpen} disabled={busy or resolved} className="mt-3 min-h-10 border border-primary px-4 text-sm font-semibold text-primary hover:bg-primary hover:text-primary-foreground disabled:opacity-50">Open official timeline</button>
            </div>}
            {timeline_open and len(timeline) == 0 and <p className="text-sm text-noir-muted">Nothing to place yet.</p>}
            <ol className="flex flex-col gap-3">
                {for entry in timeline {<li key={entry.id} className={"border-l-2 pl-3 " + kind_class(entry.kind)}>
                    <p className="font-mono text-[11px]">{entry.time} · {entry.kind.upper()}</p>
                    <p className="mt-1 text-sm leading-6 text-noir-ink">{entry.text}</p>
                </li>}}
            </ol>
        </Panel>
        <Panel title="Contradictions" subtitle="Logged automatically when a statement and a record, or two statements, disagree.">
            {len(contradictions) == 0 and <p className="text-sm text-noir-muted">None found yet. Compare what people say with the records you hold.</p>}
            <ul className="flex flex-col gap-3">
                {for item in contradictions {<li key={item.id} className="border border-noir-line bg-noir p-4">
                    <p className="font-mono text-[10px] tracking-[0.14em] text-primary/80">{item.id} · {item.significance.upper()}</p>
                    <h3 className="mt-1 font-medium text-noir-ink">{item.title}</h3>
                    <p className="mt-2 text-sm leading-6 text-noir-muted">{item.explanation}</p>
                </li>}}
            </ul>
        </Panel>
        <Panel title="Open leads">
            <ul className="flex flex-col gap-3">
                {for lead in leads {<li key={lead.id} className="flex gap-3 text-sm leading-6">
                    <span aria-hidden="true" className={"mt-1 font-mono " + ("text-emerald-200" if lead.resolved else "text-primary")}>{"✓" if lead.resolved else "○"}</span>
                    <span><span className={"font-medium " + ("text-noir-muted line-through" if lead.resolved else "text-noir-ink")}>{lead.title}</span><span className="block text-xs text-noir-muted">{lead.hint}</span></span>
                </li>}}
            </ul>
        </Panel>
    </div>;
}
