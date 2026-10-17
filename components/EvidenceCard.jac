import from .CaseStatus { CaseStatus }
sv import from ..services.caseManager { EvidenceItem }

def:pub EvidenceCard(item: EvidenceItem) -> JsxElement {
    return <article className="flex h-full flex-col border border-noir-line bg-noir-raised p-5 shadow-lg sm:p-6">
        <header className="flex flex-wrap items-start justify-between gap-3 border-b border-noir-line pb-4">
            <div><p className="font-mono text-[10px] tracking-[0.16em] text-primary/75">CLUE · {item.id}</p><h2 className="mt-2 font-serif text-xl text-noir-ink sm:text-2xl">{item.title}</h2></div>
            <CaseStatus label="SECURED" tone="open" />
        </header>
        <p className="mt-4 flex-1 text-sm leading-6 text-noir-muted">{item.summary}</p>
        <p className="mt-5 border-t border-noir-line pt-3 text-sm leading-6 text-noir-ink">{item.detail}</p>
        <div className="mt-4 flex flex-wrap gap-x-5 gap-y-2 border-t border-noir-line pt-3 font-mono text-[10px] tracking-wide text-noir-muted/80">
            <span>RECORDED {item.discovered_at}</span>
            {item.suspect_id is not None and <span>ASSOCIATED PERSON · {item.suspect_id}</span>}
        </div>
    </article>;
}
