import from ".CaseZeroShell" { CaseZeroPageContainer, CaseZeroShell }
import from "@jac/runtime" { Link }
import from ".CaseStatus" { CaseStatus }
import from ".ui.card" { Card, CardHeader, CardTitle, CardContent }
sv import from ..services.caseManager { PlayerCaseBriefing, InvestigationStartReceipt, get_missing_prototype_briefing, start_missing_prototype_investigation }

def:pub CaseBriefingScreen() -> JsxElement {
    has briefing: PlayerCaseBriefing | None = None;
    has loading: bool = True;
    has error_message: str = "";
    has starting: bool = False;
    has receipt: InvestigationStartReceipt | None = None;

    async can with entry {
        try {
            briefing = await get_missing_prototype_briefing();
            error_message = "";
        } except Exception {
            error_message = "The case briefing could not be loaded. Please try again.";
        }
        loading = False;
    }

    async def start_investigation(e: MouseEvent) {
        if starting or briefing is None { return; }
        starting = True;
        error_message = "";
        try {
            session_id = "case-001-" + str(new(Date).getTime());
            started_case = await start_missing_prototype_investigation(session_id);
            window.location.href = "/case/" + started_case.session_id;
        } except Exception {
            error_message = "The investigation could not be started. Your case briefing is still available.";
            starting = False;
        }
    }

    if loading {
        return <CaseZeroShell><CaseZeroPageContainer>
            <div className="mx-auto w-full max-w-3xl animate-pulse rounded border border-noir-line bg-noir-raised p-6 sm:p-10" aria-label="Loading case briefing">
                <div className="h-3 w-32 rounded bg-noir-muted/20" />
                <div className="mt-6 h-10 max-w-lg rounded bg-noir-muted/20" />
                <div className="mt-5 h-20 rounded bg-noir-muted/20" />
            </div>
        </CaseZeroPageContainer></CaseZeroShell>;
    }

    if briefing is None {
        return <CaseZeroShell><CaseZeroPageContainer>
            <section className="mx-auto w-full max-w-3xl border border-destructive/40 bg-noir-raised p-6 sm:p-10" role="alert">
                <p className="font-mono text-xs tracking-[0.16em] text-destructive">CASE FILE UNAVAILABLE</p>
                <h1 className="mt-4 font-serif text-3xl text-noir-ink">The briefing could not be opened</h1>
                <p className="mt-4 text-sm leading-6 text-noir-muted">{error_message}</p>
            </section>
        </CaseZeroPageContainer></CaseZeroShell>;
    }

    return <CaseZeroShell><CaseZeroPageContainer>
        <div className="relative z-10 mx-auto flex w-full max-w-5xl flex-col gap-6">
            <div className="flex flex-wrap items-start justify-between gap-4 border-b border-noir-line pb-6">
                <div>
                    <p className="font-mono text-[10px] tracking-[0.2em] text-primary/80">CASE FILE · {briefing.case_id}</p>
                    <h1 className="mt-3 font-serif text-4xl leading-tight text-noir-ink sm:text-5xl">{briefing.title}</h1>
                    <p className="mt-4 max-w-3xl text-base leading-7 text-noir-muted">{briefing.introduction}</p>
                </div>
                <CaseStatus label="OPEN CASE" tone="open" />
            </div>

            <Card className="border-noir-line bg-noir-raised text-noir-ink shadow-xl">
                <CardHeader><CardTitle className="font-serif text-2xl">The briefing</CardTitle></CardHeader>
                <CardContent><p className="text-sm leading-7 text-noir-muted sm:text-base">{briefing.briefing}</p></CardContent>
            </Card>

            <div className="grid gap-5 md:grid-cols-2">
                <Card className="border-noir-line bg-noir-raised text-noir-ink shadow-lg">
                    <CardHeader><CardTitle className="font-serif text-xl">Initial objectives</CardTitle></CardHeader>
                    <CardContent><ol className="flex flex-col gap-4">{for (objective, index) in enumerate(briefing.objectives) {<li key={str(index)} className="flex gap-3 text-sm leading-6 text-noir-muted"><span className="font-mono text-primary">0{str(index)}</span><span>{objective}</span></li>}}</ol></CardContent>
                </Card>
                <Card className="border-noir-line bg-noir-raised text-noir-ink shadow-lg">
                    <CardHeader><CardTitle className="font-serif text-xl">Known facts</CardTitle></CardHeader>
                    <CardContent><ul className="flex flex-col gap-3">{for (fact, index) in enumerate(briefing.known_facts) {<li key={str(index)} className="border-l border-primary/40 pl-3 text-sm leading-6 text-noir-muted">{fact}</li>}}</ul></CardContent>
                </Card>
            </div>

            <Card className="border-noir-line bg-noir-raised text-noir-ink shadow-lg">
                <CardHeader><CardTitle className="font-serif text-xl">Facility locations</CardTitle></CardHeader>
                <CardContent><div className="flex flex-wrap gap-2">{for location in briefing.location_names {<span key={location} className="border border-noir-line bg-noir-panel px-3 py-2 font-mono text-[10px] tracking-[0.08em] text-noir-muted">{location}</span>}}</div></CardContent>
            </Card>

            {error_message != "" and <p role="alert" className="border border-destructive/40 bg-destructive/10 p-3 text-sm text-noir-ink">{error_message}</p>}
            <div className="flex flex-wrap items-center gap-4 border-t border-noir-line pt-6">
                <button type="button" onClick={start_investigation} disabled={starting} className="h-12 w-full rounded-none border border-primary bg-primary px-7 font-semibold tracking-wide text-primary-foreground transition-colors hover:bg-primary/90 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-primary disabled:cursor-not-allowed disabled:opacity-60 sm:w-auto">
                    {"Opening investigation…" if starting else "Begin investigation"}<span aria-hidden="true" className="ml-3">→</span>
                </button>
                <span className="text-sm text-noir-muted">Four specialist advisors have rules-based fallbacks when no model key is configured.</span>
            </div>
        </div>
    </CaseZeroPageContainer></CaseZeroShell>;
}
