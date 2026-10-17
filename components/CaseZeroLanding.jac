cl import from ".ui.button" { Button }

cl def:pub CaseZeroLanding() -> JsxElement {
    has started: bool = False;

    def start_investigation(e: MouseEvent) {
        started = True;
    }

    return <main className="relative min-h-svh overflow-hidden bg-noir text-noir-ink selection:bg-primary/75 selection:text-noir">
        <div className="pointer-events-none absolute inset-0 opacity-30" style={{"backgroundImage": "radial-gradient(ellipse at 72% 34%, rgba(125, 111, 70, 0.24), transparent 48%), linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px)", "backgroundSize": "auto, 100% 5px"}} />
        <div className="pointer-events-none absolute -right-32 top-24 size-96 rounded-full bg-primary/[0.07] blur-3xl" />
        <header className="relative z-10 border-b border-noir-line">
            <nav className="mx-auto flex h-16 max-w-6xl items-center justify-between px-5 sm:px-8" aria-label="Main navigation">
                <a href="#top" className="flex items-center gap-3 text-sm font-semibold tracking-[0.24em] text-noir-ink">
                    <span className="flex size-9 items-center justify-center border border-primary/50 bg-noir-panel font-serif text-lg text-primary">C</span>
                    CASEZERO
                </a>
                <span className="hidden font-mono text-[10px] tracking-[0.18em] text-noir-muted/80 sm:block">COLD CASE DIVISION · 001</span>
                <a href="#case-file" className="text-xs uppercase tracking-[0.16em] text-noir-muted transition-colors hover:text-primary">The case</a>
            </nav>
        </header>
        <section id="top" className="relative mx-auto grid min-h-[calc(100svh-4rem)] max-w-6xl items-center gap-14 px-5 py-16 sm:px-8 lg:grid-cols-[1.05fr_0.95fr] lg:gap-20 lg:py-20">
            <div className="relative z-10 flex flex-col items-start">
                <p className="mb-6 flex items-center gap-3 font-mono text-[11px] tracking-[0.2em] text-primary/80"><span className="h-px w-8 bg-amber-300/70" />AN UNFINISHED CASE. A CITY THAT WON’T TALK.</p>
                <h1 className="max-w-2xl font-serif text-5xl font-medium leading-[1.02] tracking-[-0.035em] text-noir-ink sm:text-6xl md:text-7xl">Every answer leaves <span className="italic text-primary">a trace.</span></h1>
                <p className="mt-7 max-w-lg text-base leading-7 text-noir-muted sm:text-lg">Step into CaseZero, a mystery waiting to be opened. Read the file. Follow the evidence. Decide what the city is hiding.</p>
                <div className="mt-9 flex w-full flex-col items-start gap-4 sm:w-auto sm:flex-row sm:items-center">
                    <Button onClick={start_investigation} className="h-12 w-full rounded-none border border-primary bg-primary px-7 font-semibold tracking-wide text-primary-foreground shadow-[0_0_32px_rgba(229,190,105,0.12)] transition-colors hover:bg-primary/90 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-primary sm:w-auto">Start Investigation <span aria-hidden="true" className="ml-3">→</span></Button>
                    <span className="font-mono text-[10px] tracking-[0.14em] text-noir-muted/80">{ "CASE FILE 001 · THE MISSING PROTOTYPE" if started else "A CASEZERO ORIGINAL" }</span>
                </div>
                {started and <p role="status" className="mt-5 border-l border-primary/50 pl-3 text-sm text-primary">The case file is prepared. Your investigation begins in the next chapter.</p>}
            </div>
            <div id="case-file" className="relative mx-auto w-full max-w-xl lg:mx-0">
                <div className="absolute -inset-4 rounded-[2rem] bg-primary/[0.07] blur-2xl" />
                <article className="relative rotate-[0.6deg] border border-noir-line bg-noir-raised p-5 shadow-2xl sm:p-8">
                    <div className="absolute inset-2 border border-white/[0.04]" />
                    <div className="relative flex items-start justify-between gap-4 border-b border-noir-line pb-5">
                        <div><p className="font-mono text-[10px] tracking-[0.2em] text-primary/70">METROPOLITAN POLICE · ARCHIVE</p><h2 className="mt-2 font-serif text-2xl text-noir-ink sm:text-3xl">The Missing Prototype</h2></div>
                        <span className="shrink-0 border border-red-300/30 px-2 py-1 font-mono text-[9px] tracking-[0.18em] text-red-200/80">UNSOLVED</span>
                    </div>
                    <div className="relative grid grid-cols-2 gap-3 border-b border-noir-line py-5 font-mono text-[10px] tracking-[0.12em] sm:gap-5">
                        <div><p className="text-noir-muted/75">FILE</p><p className="mt-1.5 text-noir-ink/90">CZ–001–NX</p></div>
                        <div><p className="text-noir-muted/75">LOCATION</p><p className="mt-1.5 text-noir-ink/90">NORTH DISTRICT</p></div>
                        <div><p className="text-noir-muted/75">STATUS</p><p className="mt-1.5 text-amber-100/80">EVIDENCE PENDING</p></div>
                        <div><p className="text-noir-muted/75">CLASSIFICATION</p><p className="mt-1.5 text-noir-ink/90">RESTRICTED</p></div>
                    </div>
                    <div className="relative grid grid-cols-[1fr_auto] items-center gap-4 py-5">
                        <p className="max-w-xs font-serif text-lg leading-7 text-noir-ink/90">“The room was locked. The prototype was gone. Nobody heard a thing.”</p>
                        <div className="flex size-16 rotate-[-12deg] items-center justify-center rounded-full border-2 border-red-300/35 text-center font-mono text-[8px] leading-3 tracking-[0.12em] text-red-200/65">CASE<br/>OPEN</div>
                    </div>
                    <div className="relative border-t border-dashed border-noir-line pt-4 font-mono text-[9px] tracking-[0.14em] text-noir-muted">ARCHIVE COPY · HANDLE WITH CARE</div>
                </article>
                <div className="absolute -bottom-4 -left-3 hidden -rotate-6 border border-primary/20 bg-primary px-4 py-2 font-mono text-[9px] tracking-[0.16em] text-primary-foreground shadow-lg sm:block">EVIDENCE LOG · 01</div>
            </div>
        </section>
        <footer className="relative border-t border-noir-line px-5 py-5 sm:px-8">
            <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 font-mono text-[9px] tracking-[0.16em] text-noir-muted/75"><span>CASEZERO · THE MYSTERY ROOM</span><span>FICTIONAL CASE · FILE 001</span></div>
        </footer>
    </main>;
}
