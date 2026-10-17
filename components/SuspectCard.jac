import from .CaseStatus { CaseStatus }
sv import from ..services.caseManager { SuspectPublicProfile }

def:pub SuspectCard(suspect: SuspectPublicProfile) -> JsxElement {
    return <article className="flex h-full flex-col border border-noir-line bg-noir-raised p-5 shadow-lg sm:p-6">
        <div className="flex flex-wrap items-start justify-between gap-3 border-b border-noir-line pb-4">
            <div>
                <p className="font-mono text-[10px] tracking-[0.18em] text-primary/75">{suspect.role}</p>
                <h2 className="mt-2 font-serif text-2xl text-noir-ink">{suspect.name}</h2>
            </div>
            <CaseStatus label={"INTERVIEWED" if suspect.interview_started else "NOT INTERVIEWED"} tone={"open" if suspect.interview_started else "unresolved"} />
        </div>
        <p className="mt-4 flex-1 text-sm leading-6 text-noir-muted">{suspect.profile}</p>
        <div className="mt-5 border-t border-noir-line pt-3 font-mono text-[9px] tracking-[0.14em] text-noir-muted/80">
            {"INTERVIEW ON RECORD" if suspect.interview_started else "AWAITING INTERVIEW"}
        </div>
    </article>;
}
