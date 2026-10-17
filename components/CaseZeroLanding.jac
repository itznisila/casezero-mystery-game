cl import from ".CaseActionButton" { CaseActionButton }
cl import from ".CaseFilePanel" { CaseFilePanel }
cl import from ".CaseStatus" { CaseStatus }
cl import from ".CaseZeroShell" { CaseZeroPageContainer, CaseZeroShell }

def:pub CaseZeroLanding() -> JsxElement {
    has started: bool = False;

    def start_investigation(e: MouseEvent) {
        started = True;
    }

    return <CaseZeroShell>
        <CaseZeroPageContainer>
            <div className="relative z-10 flex flex-col items-start">
                <p className="mb-6 flex items-center gap-3 font-mono text-[11px] tracking-[0.2em] text-primary/80"><span className="h-px w-8 bg-primary/70" />AN UNFINISHED CASE. A CITY THAT WON’T TALK.</p>
                <h1 className="max-w-2xl font-serif text-5xl font-medium leading-[1.02] tracking-[-0.035em] text-noir-ink sm:text-6xl md:text-7xl">Every answer leaves <span className="italic text-primary">a trace.</span></h1>
                <p className="mt-7 max-w-lg text-base leading-7 text-noir-muted sm:text-lg">Step into CaseZero, a mystery waiting to be opened. Read the file. Follow the evidence. Decide what the city is hiding.</p>
                <div className="mt-9 flex w-full flex-col items-start gap-4 sm:w-auto sm:flex-row sm:items-center">
                    <CaseActionButton label="Start Investigation" onClick={start_investigation}>→</CaseActionButton>
                    <span className="font-mono text-[10px] tracking-[0.14em] text-noir-muted/80">{ "CASE FILE 001 · THE MISSING PROTOTYPE" if started else "A CASEZERO ORIGINAL" }</span>
                </div>
                {started and <p role="status" className="mt-5 border-l border-primary/50 pl-3 text-sm text-primary">The case file is prepared. Your investigation begins in the next chapter.</p>}
            </div>
            <div id="case-file" className="relative mx-auto w-full max-w-xl lg:mx-0">
                <div aria-hidden="true" className="absolute -inset-4 rounded-[2rem] bg-primary/[0.07] blur-2xl" />
                <CaseFilePanel>
                    <div className="relative flex items-start justify-between gap-4 border-b border-noir-line pb-5">
                        <div><p className="font-mono text-[10px] tracking-[0.2em] text-primary/70">METROPOLITAN POLICE · ARCHIVE</p><h2 className="mt-2 font-serif text-2xl text-noir-ink sm:text-3xl">The Missing Prototype</h2></div>
                        <CaseStatus label="UNSOLVED" tone="unresolved" />
                    </div>
                    <div className="relative grid grid-cols-2 gap-3 border-b border-noir-line py-5 font-mono text-[10px] tracking-[0.12em] sm:gap-5">
                        <div><p className="text-noir-muted/75">FILE</p><p className="mt-1.5 text-noir-ink/90">CZ–001–NX</p></div>
                        <div><p className="text-noir-muted/75">LOCATION</p><p className="mt-1.5 text-noir-ink/90">NORTH DISTRICT</p></div>
                        <div><p className="text-noir-muted/75">STATUS</p><p className="mt-1.5 text-primary">EVIDENCE PENDING</p></div>
                        <div><p className="text-noir-muted/75">CLASSIFICATION</p><p className="mt-1.5 text-noir-ink/90">RESTRICTED</p></div>
                    </div>
                    <div className="relative grid grid-cols-[1fr_auto] items-center gap-4 py-5">
                        <p className="max-w-xs font-serif text-lg leading-7 text-noir-ink/90">“The room was locked. The prototype was gone. Nobody heard a thing.”</p>
                        <div className="flex size-16 rotate-[-12deg] items-center justify-center rounded-full border-2 border-red-300/35 text-center font-mono text-[8px] leading-3 tracking-[0.12em] text-red-200/65">CASE<br/>OPEN</div>
                    </div>
                    <div className="relative border-t border-dashed border-noir-line pt-4 font-mono text-[9px] tracking-[0.14em] text-noir-muted">ARCHIVE COPY · HANDLE WITH CARE</div>
                </CaseFilePanel>
                <div className="absolute -bottom-4 -left-3 hidden -rotate-6 border border-primary/20 bg-primary px-4 py-2 font-mono text-[9px] tracking-[0.16em] text-primary-foreground shadow-lg sm:block">EVIDENCE LOG · 01</div>
            </div>
        </CaseZeroPageContainer>
    </CaseZeroShell>;
}
