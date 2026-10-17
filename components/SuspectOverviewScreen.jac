import from "@jac/runtime" { useParams }
import from .CaseZeroShell { CaseZeroPageContainer, CaseZeroShell }
import from .SuspectCard { SuspectCard }
sv import from ..services.caseManager { SuspectPublicProfile, get_suspect_overview }

def:pub SuspectOverviewScreen() -> JsxElement {
    has suspects: list[SuspectPublicProfile] = [];
    has loading: bool = True;
    has error_message: str = "";
    params = useParams();
    session_id = params["session_id"];

    async can with entry {
        if session_id {
            try {
                suspects = await get_suspect_overview(str(session_id));
                error_message = "";
            } except Exception {
                error_message = "Suspect profiles could not be loaded for this investigation.";
            }
        } else {
            error_message = "An active investigation session is required to view suspect progress.";
        }
        loading = False;
    }

    if loading {
        return <CaseZeroShell><CaseZeroPageContainer>
            <div className="mx-auto w-full max-w-6xl animate-pulse" aria-label="Loading suspect profiles">
                <div className="h-3 w-40 rounded bg-noir-muted/20" />
                <div className="mt-5 h-10 w-72 rounded bg-noir-muted/20" />
                <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3"><div className="h-56 rounded border border-noir-line bg-noir-raised"/><div className="h-56 rounded border border-noir-line bg-noir-raised"/><div className="h-56 rounded border border-noir-line bg-noir-raised"/></div>
            </div>
        </CaseZeroPageContainer></CaseZeroShell>;
    }

    if error_message != "" {
        return <CaseZeroShell><CaseZeroPageContainer>
            <section className="mx-auto w-full max-w-3xl border border-destructive/40 bg-noir-raised p-6 sm:p-10" role="alert">
                <p className="font-mono text-xs tracking-[0.16em] text-destructive">INVESTIGATION UNAVAILABLE</p>
                <h1 className="mt-4 font-serif text-3xl text-noir-ink">Suspect overview unavailable</h1>
                <p className="mt-4 text-sm leading-6 text-noir-muted">{error_message}</p>
            </section>
        </CaseZeroPageContainer></CaseZeroShell>;
    }

    return <CaseZeroShell><CaseZeroPageContainer>
        <section className="relative z-10 mx-auto flex w-full max-w-6xl flex-col gap-7">
            <header className="border-b border-noir-line pb-6">
                <p className="font-mono text-[10px] tracking-[0.2em] text-primary/80">ACTIVE INVESTIGATION · CASE 001</p>
                <h1 className="mt-3 font-serif text-4xl leading-tight text-noir-ink sm:text-5xl">People of interest</h1>
                <p className="mt-4 max-w-3xl text-base leading-7 text-noir-muted">Review each staff member's public background. Interview progress updates as you question them.</p>
            </header>
            <p className="font-mono text-[10px] tracking-[0.14em] text-noir-muted/80">SESSION · {str(session_id)}</p>
            <div className="grid items-stretch gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {for suspect in suspects {<SuspectCard key={suspect.id} suspect={suspect} />}}
            </div>
        </section>
    </CaseZeroPageContainer></CaseZeroShell>;
}
