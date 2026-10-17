def:pub CaseZeroHeader() -> JsxElement {
    return <header className="relative z-10 border-b border-noir-line">
        <nav className="mx-auto flex h-16 max-w-6xl items-center justify-between px-5 sm:px-8" aria-label="Main navigation">
            <a href="#top" className="flex items-center gap-3 text-sm font-semibold tracking-[0.24em] text-noir-ink focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-primary">
                <span className="flex size-9 items-center justify-center border border-primary/50 bg-noir-panel font-serif text-lg text-primary">C</span>
                CASEZERO
            </a>
            <span className="hidden font-mono text-[10px] tracking-[0.18em] text-noir-muted/80 sm:block">COLD CASE DIVISION · 001</span>
            <a href="#case-file" className="text-xs uppercase tracking-[0.16em] text-noir-muted transition-colors hover:text-primary focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-primary">The case</a>
        </nav>
    </header>;
}

def:pub CaseZeroPageContainer(children: any = None) -> JsxElement {
    return <section id="top" className="relative mx-auto grid min-h-[calc(100svh-4rem)] w-full max-w-6xl items-center gap-14 px-5 py-16 sm:px-8 lg:grid-cols-[1.05fr_0.95fr] lg:gap-20 lg:py-20">{children}</section>;
}

def:pub CaseZeroShell(children: any = None) -> JsxElement {
    return <main className="relative min-h-svh overflow-hidden bg-noir text-noir-ink selection:bg-primary/75 selection:text-noir">
        <div aria-hidden="true" className="pointer-events-none absolute inset-0 opacity-30" style={{"backgroundImage": "radial-gradient(ellipse at 72% 34%, rgba(125, 111, 70, 0.24), transparent 48%), linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px)", "backgroundSize": "auto, 100% 5px"}} />
        <div aria-hidden="true" className="pointer-events-none absolute -right-32 top-24 size-96 rounded-full bg-primary/[0.07] blur-3xl" />
        <CaseZeroHeader />
        {children}
        <footer className="relative border-t border-noir-line px-5 py-5 sm:px-8">
            <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 font-mono text-[9px] tracking-[0.16em] text-noir-muted/75"><span>CASEZERO · THE MYSTERY ROOM</span><span>FICTIONAL CASE · FILE 001</span></div>
        </footer>
    </main>;
}
