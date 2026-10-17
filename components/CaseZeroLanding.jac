cl import from ".ui.button" { Button }

cl def:pub CaseZeroLanding() -> JsxElement {
    has started: bool = False;

    def start_investigation(e: MouseEvent) {
        started = True;
    }

    return <main className="relative min-h-svh overflow-hidden bg-[#10120f] text-stone-100 selection:bg-amber-300 selection:text-stone-950">
        <div className="pointer-events-none absolute inset-0 opacity-30" style={{"backgroundImage": "radial-gradient(ellipse at 72% 34%, rgba(125, 111, 70, 0.24), transparent 48%), linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px)", "backgroundSize": "auto, 100% 5px"}} />
        <div className="pointer-events-none absolute -right-32 top-24 size-96 rounded-full bg-amber-200/[0.06] blur-3xl" />
        <header className="relative z-10 border-b border-white/10">
            <nav className="mx-auto flex h-16 max-w-6xl items-center justify-between px-5 sm:px-8" aria-label="Main navigation">
                <a href="#top" className="flex items-center gap-3 text-sm font-semibold tracking-[0.24em] text-stone-100">
                    <span className="flex size-9 items-center justify-center border border-amber-300/50 font-serif text-lg text-amber-200">C</span>
                    CASEZERO
                </a>
                <span className="hidden font-mono text-[10px] tracking-[0.18em] text-stone-500 sm:block">COLD CASE DIVISION · 001</span>
                <a href="#case-file" className="text-xs uppercase tracking-[0.16em] text-stone-400 transition-colors hover:text-amber-200">The case</a>
            </nav>
        </header>
        <section id="top" className="relative mx-auto grid min-h-[calc(100svh-4rem)] max-w-6xl items-center gap-14 px-5 py-16 sm:px-8 lg:grid-cols-[1.05fr_0.95fr] lg:gap-20 lg:py-20">
            <div className="relative z-10 flex flex-col items-start">
                <p className="mb-6 flex items-center gap-3 font-mono text-[11px] tracking-[0.2em] text-amber-200/80"><span className="h-px w-8 bg-amber-300/70" />AN UNFINISHED CASE. A CITY THAT WON’T TALK.</p>
                <h1 className="max-w-2xl font-serif text-5xl font-medium leading-[1.02] tracking-[-0.035em] text-stone-100 sm:text-6xl md:text-7xl">Every answer leaves <span className="italic text-amber-200">a trace.</span></h1>
                <p className="mt-7 max-w-lg text-base leading-7 text-stone-400 sm:text-lg">Step into CaseZero, a mystery waiting to be opened. Read the file. Follow the evidence. Decide what the city is hiding.</p>
                <div className="mt-9 flex w-full flex-col items-start gap-4 sm:w-auto sm:flex-row sm:items-center">
                    <Button onClick={start_investigation} className="h-12 w-full rounded-none border border-amber-200 bg-amber-200 px-7 font-semibold tracking-wide text-stone-950 shadow-[0_0_32px_rgba(229,190,105,0.12)] transition-colors hover:bg-amber-100 sm:w-auto">Start Investigation <span aria-hidden="true" className="ml-3">→</span></Button>
                    <span className="font-mono text-[10px] tracking-[0.14em] text-stone-500">{ "CASE FILE 001 · THE MISSING PROTOTYPE" if started else "A CASEZERO ORIGINAL" }</span>
                </div>
                {started and <p role="status" className="mt-5 border-l border-amber-300/50 pl-3 text-sm text-amber-100">The case file is prepared. Your investigation begins in the next chapter.</p>}
            </div>
            <div id="case-file" className="relative mx-auto w-full max-w-xl lg:mx-0">
                <div className="absolute -inset-4 rounded-[2rem] bg-amber-200/[0.06] blur-2xl" />
                <article className="relative rotate-[0.6deg] border border-stone-500/30 bg-[#1c1e19] p-5 shadow-2xl sm:p-8">
                    <div className="absolute inset-2 border border-white/[0.04]" />
                    <div className="relative flex items-start justify-between gap-4 border-b border-white/10 pb-5">
                        <div><p className="font-mono text-[10px] tracking-[0.2em] text-amber-200/70">METROPOLITAN POLICE · ARCHIVE</p><h2 className="mt-2 font-serif text-2xl text-stone-100 sm:text-3xl">The Missing Prototype</h2></div>
                        <span className="shrink-0 border border-red-300/30 px-2 py-1 font-mono text-[9px] tracking-[0.18em] text-red-200/80">UNSOLVED</span>
                    </div>
                    <div className="relative grid grid-cols-2 gap-3 border-b border-white/10 py-5 font-mono text-[10px] tracking-[0.12em] sm:gap-5">
                        <div><p className="text-stone-600">FILE</p><p className="mt-1.5 text-stone-300">CZ–001–NX</p></div>
                        <div><p className="text-stone-600">LOCATION</p><p className="mt-1.5 text-stone-300">NORTH DISTRICT</p></div>
                        <div><p className="text-stone-600">STATUS</p><p className="mt-1.5 text-amber-100/80">EVIDENCE PENDING</p></div>
                        <div><p className="text-stone-600">CLASSIFICATION</p><p className="mt-1.5 text-stone-300">RESTRICTED</p></div>
                    </div>
                    <div className="relative grid grid-cols-[1fr_auto] items-center gap-4 py-5">
                        <p className="max-w-xs font-serif text-lg leading-7 text-stone-300">“The room was locked. The prototype was gone. Nobody heard a thing.”</p>
                        <div className="flex size-16 rotate-[-12deg] items-center justify-center rounded-full border-2 border-red-300/35 text-center font-mono text-[8px] leading-3 tracking-[0.12em] text-red-200/65">CASE<br/>OPEN</div>
                    </div>
                    <div className="relative border-t border-dashed border-stone-600/60 pt-4 font-mono text-[9px] tracking-[0.14em] text-stone-600">ARCHIVE COPY · HANDLE WITH CARE</div>
                </article>
                <div className="absolute -bottom-4 -left-3 hidden -rotate-6 border border-amber-100/10 bg-[#d8c69b] px-4 py-2 font-mono text-[9px] tracking-[0.16em] text-stone-800 shadow-lg sm:block">EVIDENCE LOG · 01</div>
            </div>
        </section>
        <footer className="relative border-t border-white/10 px-5 py-5 sm:px-8">
            <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 font-mono text-[9px] tracking-[0.16em] text-stone-600"><span>CASEZERO · THE MYSTERY ROOM</span><span>FICTIONAL CASE · FILE 001</span></div>
        </footer>
    </main>;
}
