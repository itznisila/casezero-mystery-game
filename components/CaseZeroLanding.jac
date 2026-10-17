import from "@jac/runtime" { Link }
import from .CaseActionButton { CaseActionButton }
import from .CaseFilePanel { CaseFilePanel }
import from .CaseStatus { CaseStatus }
import from .CaseZeroShell { CaseZeroPageContainer, CaseZeroShell }


def:pub CaseZeroLanding() -> JsxElement {
    return <CaseZeroShell>
        <CaseZeroPageContainer>
            <div className="relative z-10 flex flex-col items-start">
                <p className="mb-6 flex items-center gap-3 font-mono text-[11px] tracking-[0.2em] text-primary/80"><span className="h-px w-8 bg-primary/70" />THE NORTHSTAR FACILITY · CASE FILE 001</p>
                <h1 className="max-w-2xl font-serif text-5xl font-medium leading-[1.02] tracking-[-0.035em] text-noir-ink sm:text-6xl md:text-7xl">Every answer leaves <span className="italic text-primary">a trace.</span></h1>
                <p className="mt-7 max-w-lg text-base leading-7 text-noir-muted sm:text-lg">Question three suspects, trace a prototype through a locked facility, and build a case from verified evidence.</p>
                <div className="mt-9 flex w-full flex-col items-start gap-4 sm:w-auto sm:flex-row sm:items-center">
                    <Link to="/briefing" className="inline-flex w-full sm:w-auto"><CaseActionButton label="Open the case file" onClick={lambda (e: MouseEvent) {}}>→</CaseActionButton></Link>
                    <span className="font-mono text-[10px] tracking-[0.14em] text-noir-muted/80">A DETERMINISTIC MYSTERY · AI ADVISORS OPTIONAL</span>
                </div>
                <div className="mt-10 flex flex-wrap gap-x-7 gap-y-2 border-t border-noir-line pt-5 font-mono text-[10px] tracking-[0.12em] text-noir-muted"><span>3 PEOPLE OF INTEREST</span><span>6 FACILITY LOCATIONS</span><span>ONE FIXED SOLUTION</span></div>
            </div>
            <div id="case-file" className="relative mx-auto w-full max-w-xl lg:mx-0">
                <div aria-hidden="true" className="absolute -inset-4 rounded-[2rem] bg-primary/[0.07] blur-2xl" />
                <CaseFilePanel>
                    <div className="relative flex items-start justify-between gap-4 border-b border-noir-line pb-5"><div><p className="font-mono text-[10px] tracking-[0.2em] text-primary/70">NORTHSTAR RESEARCH · ARCHIVE</p><h2 className="mt-2 font-serif text-2xl text-noir-ink sm:text-3xl">The Missing Prototype</h2></div><CaseStatus label="CASE OPEN" tone="open" /></div>
                    <div className="relative grid grid-cols-2 gap-3 border-b border-noir-line py-5 font-mono text-[10px] tracking-[0.12em] sm:gap-5">
                        <div><p className="text-noir-muted/75">FILE</p><p className="mt-1.5 text-noir-ink/90">CZ–001–NX</p></div><div><p className="text-noir-muted/75">INCIDENT</p><p className="mt-1.5 text-noir-ink/90">21:30 · NORTHSTAR</p></div>
                        <div><p className="text-noir-muted/75">ACCESS</p><p className="mt-1.5 text-primary">NO FORCED ENTRY</p></div><div><p className="text-noir-muted/75">LEADS</p><p className="mt-1.5 text-noir-ink/90">3 STAFF MEMBERS</p></div>
                    </div>
                    <div className="relative py-5"><p className="font-serif text-lg leading-7 text-noir-ink/90">“The archive was locked. The alarm stayed silent. The trail begins with an authorized credential.”</p></div>
                    <div className="relative border-t border-dashed border-noir-line pt-4 font-mono text-[9px] tracking-[0.14em] text-noir-muted">CASE ENGINE · FIXED FACTS · ADVISORY AGENTS</div>
                </CaseFilePanel>
            </div>
        </CaseZeroPageContainer>
    </CaseZeroShell>;
}
