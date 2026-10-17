import from "@jac/runtime" { useParams }
import from .CaseZeroShell { CaseZeroPageContainer, CaseZeroShell }
import from .EvidenceCard { EvidenceCard }
import from .EvidenceInspectButton { EvidenceInspectButton }
sv import from ..services.caseManager { EvidenceCollection, get_session_evidence_api, EvidenceItem }

def:pub EvidenceScreen() -> JsxElement {
    has collection: EvidenceCollection | None = None;
    has error_message: str = "";
    has loading: bool = True;
    params = useParams();
    session_id = params["session_id"];
    async can with entry {
        if session_id {
            try { collection = await get_session_evidence_api(str(session_id)); }
            except Exception { error_message = "Evidence records could not be loaded for this investigation."; }
        } else { error_message = "An active investigation session is required to view evidence."; }
        loading = False;
    }
    async def refresh_evidence {
        try { collection = await get_session_evidence_api(str(session_id)); }
        except Exception { error_message = "Evidence records could not be refreshed."; }
    }
    clues: list[EvidenceItem] = [];
    if collection is not None { clues = collection.discovered; }
    if loading { return <CaseZeroShell><CaseZeroPageContainer><section aria-label="Loading evidence" className="mx-auto w-full max-w-6xl animate-pulse border border-noir-line bg-noir-raised p-8"><div className="h-8 w-64 rounded bg-noir-muted/20"/><div className="mt-6 h-32 rounded bg-noir-muted/20"/></section></CaseZeroPageContainer></CaseZeroShell>; }
    return <CaseZeroShell><CaseZeroPageContainer><section className="relative z-10 mx-auto flex w-full max-w-6xl flex-col gap-7">
        <header className="border-b border-noir-line pb-6"><p className="font-mono text-[10px] tracking-[0.2em] text-primary/80">ACTIVE INVESTIGATION · CASE 001</p><h1 className="mt-3 font-serif text-4xl text-noir-ink sm:text-5xl">Evidence file</h1><p className="mt-4 max-w-3xl text-base leading-7 text-noir-muted">Discovered clues, verified descriptions, and authorized metadata appear here. Undiscovered evidence remains hidden.</p></header>
        <p className="font-mono text-[10px] tracking-[0.14em] text-noir-muted/80">SESSION · {str(session_id)}</p>
        {error_message if error_message != "" else ""}
        {<p className="border border-dashed border-noir-line bg-noir-raised p-8 text-center text-sm text-noir-muted">Your evidence file is empty. No clues have been discovered in this investigation yet.</p> if len(clues) == 0 else ""}
        <div className="grid gap-4 md:grid-cols-2">{for clue in clues {<EvidenceCard key={clue.id} item={clue}/>}}</div>
        {if collection is not None and len(collection.available_ids) > 0 {<section className="border-t border-noir-line pt-6"><h2 className="font-serif text-2xl text-noir-ink">Available for inspection</h2><p className="mt-2 text-sm text-noir-muted">Details remain sealed until an authorized inspection succeeds.</p><ul className="mt-4 flex flex-col gap-3">{for evidence_id in collection.available_ids {<li key={evidence_id} className="flex flex-wrap items-center justify-between gap-3 border border-noir-line bg-noir-raised p-4"><span className="font-mono text-xs text-primary/80">SEALED LEAD · {evidence_id}</span><EvidenceInspectButton session_id={str(session_id)} evidence_id={evidence_id} on_discovered={refresh_evidence}/></li>}}</ul></section>}}
    </section></CaseZeroPageContainer></CaseZeroShell>;
}
