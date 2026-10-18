import from .Panel { Panel }
sv import from ..services.gameApi { LocationView }

def:pub LocationsPanel(locations: list[LocationView], busy: bool, resolved: bool, onVisit: any, onSecure: any) -> JsxElement {
    return <Panel title="Facility locations" subtitle="Visit a location to read what is there. Records can only be secured where they are found.">
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {for loc in locations {<article key={loc.id} className="flex flex-col border border-noir-line bg-noir p-4">
                <div className="flex items-start justify-between gap-2">
                    <h3 className="font-medium text-noir-ink">{loc.name}</h3>
                    <span className="shrink-0 font-mono text-[9px] tracking-[0.14em] text-noir-muted">{"VISITED" if loc.visited else "NOT VISITED"}</span>
                </div>
                <p className="mt-2 text-xs leading-5 text-noir-muted">{loc.description}</p>
                {loc.visited and <p className="mt-3 border-l border-primary/50 pl-3 text-xs leading-5 text-noir-ink">{loc.note}</p>}
                {loc.visited and len(loc.items) > 0 and <ul className="mt-3 flex flex-col gap-2">
                    {for item in loc.items {<li key={item.id} className="flex items-center justify-between gap-2 border border-noir-line px-3 py-2">
                        <span className="text-xs text-noir-ink">{item.title}</span>
                        <button type="button" disabled={busy or resolved} onClick={lambda { onSecure(item.id); }} className="min-h-9 border border-primary px-3 text-xs font-semibold text-primary hover:bg-primary hover:text-primary-foreground disabled:cursor-not-allowed disabled:opacity-50">Secure</button>
                    </li>}}
                </ul>}
                {loc.visited and len(loc.items) == 0 and <p className="mt-3 font-mono text-[10px] tracking-[0.12em] text-noir-muted/80">NOTHING LEFT TO SECURE HERE</p>}
                {not loc.visited and <button type="button" disabled={busy or resolved} onClick={lambda { onVisit(loc.id); }} className="mt-4 min-h-10 border border-noir-line px-4 text-sm text-noir-ink hover:border-primary disabled:cursor-not-allowed disabled:opacity-50">Visit location</button>}
            </article>}}
        </div>
    </Panel>;
}
