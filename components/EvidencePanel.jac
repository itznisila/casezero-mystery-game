import from .Panel { Panel }
import from .EvidenceCard { EvidenceCard }
sv import from ..services.gameApi { EvidenceItem, RevealedStatement, SuspectPublicProfile }

def:pub EvidencePanel(evidence: list[EvidenceItem], total: int, statements: list[RevealedStatement], suspects: list[SuspectPublicProfile]) -> JsxElement {
    def name_of(suspect_id: str) -> str {
        for person in suspects {
            if person.id == suspect_id { return person.name; }
        }
        return suspect_id;
    }

    return <div className="flex flex-col gap-5">
        <Panel title="Evidence board" subtitle={str(len(evidence)) + " of " + str(total) + " records secured. Statements below are unverified until a record confirms them."}>
            {len(evidence) == 0 and <p className="border border-dashed border-noir-line p-5 text-sm leading-6 text-noir-muted">No evidence secured yet. Open the Locations tab, visit a place, and secure what you find.</p>}
            <div className="grid gap-4 md:grid-cols-2">
                {for item in evidence {<EvidenceCard key={item.id} item={item} />}}
            </div>
        </Panel>
        <Panel title="Statements on record" subtitle="What each person has told you so far.">
            {len(statements) == 0 and <p className="border border-dashed border-noir-line p-5 text-sm leading-6 text-noir-muted">Nobody has been questioned yet. Use the Interviews tab.</p>}
            <ul className="flex flex-col gap-3">
                {for st in statements {<li key={st.id} className="border border-noir-line bg-noir p-4">
                    <p className="font-mono text-[10px] tracking-[0.14em] text-primary/80">{name_of(st.suspect_id)} · {st.kind.upper()} · {st.topic.upper()}</p>
                    <p className="mt-2 text-sm leading-6 text-noir-ink">{st.line}</p>
                </li>}}
            </ul>
        </Panel>
    </div>;
}
