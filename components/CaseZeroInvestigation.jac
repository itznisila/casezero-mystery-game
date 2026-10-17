sv import from ..services.caseService { CaseFile, getCase, discoverClue, interviewSuspect, accuseSuspect }
import from .ui.card { Card, CardHeader, CardTitle, CardDescription, CardContent }
import from .ui.button { Button }
import from .ui.input { Input }
import from .ui.textarea { Textarea }

cl def:pub CaseZeroInvestigation() -> JsxElement {
    has case_file: CaseFile | None = None;
    has loading: bool = True;
    has discovered: list[str] = [];
    has selected_suspect: str = "mara";
    has question: str = "";
    has answer: str = "";
    has accusation: str = "";
    has case_note: str = "";
    has verdict: str = "";
    has error_message: str = "";
    has busy: bool = False;
    async can with entry { try { case_file = await getCase(); loading = False; } except Exception { loading = False; error_message = "Could not load case file. Refresh to retry."; } }
    def update_question(e: ChangeEvent) { question = e.target.value; }
    def update_accusation(e: ChangeEvent) { accusation = e.target.value; }
    def update_note(e: ChangeEvent) { case_note = e.target.value; }
    async def inspect(clue_id: str) {
        busy = True;
        try { clue = await discoverClue(clue_id); if clue != None and not (clue_id in discovered) { discovered = discovered + [clue_id]; } }
        except Exception { error_message = "Evidence inspection failed. Retry."; }
        busy = False;
    }
    async def interview {
        if not question.strip() { return; }
        busy = True;
        try { answer = await interviewSuspect(selected_suspect, question, ""); question = ""; error_message = ""; }
        except Exception { error_message = "Interview unavailable. Secured evidence is preserved."; }
        busy = False;
    }
    async def submit_accusation {
        if not accusation { verdict = "Select a suspect before submitting."; return; }
        busy = True;
        try { result = await accuseSuspect(accusation, case_note, discovered); verdict = result["message"] as str; }
        except Exception { error_message = "Accusation check failed. Retry."; }
        busy = False;
    }
    if loading { return <main className="min-h-svh bg-[#0b0f14] p-8 text-zinc-100">Opening case file…</main>; }
    if case_file == None { return <main className="min-h-svh bg-[#0b0f14] p-8 text-zinc-100"><h1>Case file unavailable</h1><p>{error_message}</p></main>; }
    next_action = "Inspect the access log to test Mara's alibi.";
    if "E-01" in discovered { next_action = "Inspect the maintenance ticket to trace the freight lift override."; }
    if "E-01" in discovered and "E-03" in discovered { next_action = "Compare Mara's account with the archive entry and lift route."; }
    return <main className="min-h-svh bg-[#0b0f14] text-zinc-100">
        <header className="border-b border-white/10 bg-[#10161d] px-5 py-4"><div className="mx-auto flex max-w-7xl flex-wrap items-center justify-between gap-3"><div><div className="font-semibold tracking-[0.2em] text-amber-300">CASEZERO</div><div className="text-xs text-zinc-500">THE AGENTIC MYSTERY ROOM</div></div><Badge variant="outline" className="border-amber-300/30 text-amber-200">DEMO MODE · RULES ENGINE ACTIVE</Badge></div></header>
        <div className="mx-auto flex max-w-7xl flex-col gap-6 px-5 py-7">
            {error_message and <p className="rounded-lg border border-red-900 bg-red-950/40 p-3 text-sm text-red-200">{error_message}</p>}
            <section className="flex flex-wrap items-end justify-between gap-4 border-b border-white/10 pb-6"><div className="max-w-3xl"><p className="mb-2 text-xs uppercase tracking-[0.18em] text-amber-300">Active investigation · Case 001</p><h1 className="text-3xl font-semibold tracking-tight sm:text-4xl">{case_file.title}</h1><p className="mt-3 text-sm leading-6 text-zinc-400">{case_file.briefing}</p></div><p className="text-sm text-zinc-400">{str(len(discovered))} of 4 evidence items secured</p></section>
            <div className="grid gap-5 xl:grid-cols-12"><section className="flex flex-col gap-5 xl:col-span-8">
                <Card className="border-white/10 bg-[#111820] text-zinc-100 shadow-lg"><CardHeader><CardTitle>Evidence board</CardTitle><CardDescription className="text-zinc-500">Inspect each item to add its verified detail to the case file.</CardDescription></CardHeader><CardContent><div className="grid gap-3 sm:grid-cols-2">{for clue in case_file.clues {<article key={clue.id} className="rounded-lg border border-white/10 bg-[#0c1117] p-4"><div className="font-mono text-xs text-amber-300">{clue.id} · {clue.time}</div><h3 className="mt-2 font-medium">{clue.title}</h3><p className="mt-2 text-sm leading-5 text-zinc-400">{clue.summary}</p>{if clue.id in discovered {<p className="mt-3 rounded-md bg-amber-300/[0.05] p-3 text-xs leading-5 text-zinc-200">{clue.detail}</p>}}<Button variant="outline" size="sm" disabled={busy or clue.id in discovered} onClick={lambda { inspect(clue.id); }} className="mt-3 border-white/15 bg-transparent text-zinc-200">Inspect evidence</Button></article>}}</div></CardContent></Card>
                <Card className="border-white/10 bg-[#111820] text-zinc-100 shadow-lg"><CardHeader><CardTitle>Suspect interviews</CardTitle><CardDescription className="text-zinc-500">Demo mode uses fixed, case-consistent suspect responses.</CardDescription></CardHeader><CardContent className="flex flex-col gap-4"><div className="flex flex-wrap gap-2">{for suspect in case_file.suspects {<Button key={suspect.id} variant="outline" size="sm" onClick={lambda { selected_suspect = suspect.id; }} className="border-white/15 bg-transparent text-zinc-200">{suspect.name}</Button>}}</div>{for suspect in case_file.suspects {if selected_suspect == suspect.id {<div key={suspect.id} className="rounded-lg border border-white/10 bg-[#0c1117] p-4"><h3 className="font-medium">{suspect.name} · {suspect.role}</h3><p className="mt-2 text-sm text-zinc-400">{suspect.profile}</p><p className="mt-3 text-xs leading-5 text-zinc-400">ALIBI · {suspect.alibi}</p><p className="mt-2 text-xs leading-5 text-zinc-400">MOTIVE · {suspect.motive}</p></div>}}}<div className="flex flex-wrap gap-2"><Input value={question} onChange={update_question} placeholder="Ask about the alibi or the freight lift" maxLength={500} className="min-w-48 flex-1 border-white/10 bg-[#0c1117] text-zinc-100"/><Button onClick={interview} disabled={busy or not question.strip()} className="bg-amber-400 text-zinc-950">Ask suspect</Button></div>{answer != "" and <p className="rounded-lg border border-white/10 bg-[#0c1117] p-4 text-sm leading-6 text-zinc-200">{answer}</p>}</CardContent></Card>
            </section><aside className="flex flex-col gap-5 xl:col-span-4"><Card className="border-amber-300/20 bg-[#171811] text-zinc-100 shadow-lg"><CardHeader><CardTitle>Lead detective</CardTitle><CardDescription className="text-zinc-500">Deterministic case manager · verified facts only</CardDescription></CardHeader><CardContent><p className="rounded-lg border border-amber-300/10 bg-black/20 p-4 text-sm leading-6">{next_action}</p><p className="mt-3 text-xs leading-5 text-zinc-500">The action updates from secured case evidence. The official solution cannot change.</p></CardContent></Card>
                <Card className="border-white/10 bg-[#111820] text-zinc-100 shadow-lg"><CardHeader><CardTitle>Official timeline</CardTitle></CardHeader><CardContent><ol className="flex flex-col gap-3">{for (event, index) in enumerate(case_file.timeline) {<li key={str(index)} className="border-l border-amber-300/30 pl-3 text-xs leading-5 text-zinc-400">{event}</li>}}</ol></CardContent></Card>
                <Card className="border-white/10 bg-[#111820] text-zinc-100 shadow-lg"><CardHeader><CardTitle>Final accusation</CardTitle><CardDescription className="text-zinc-500">A supported charge requires E-01 and E-03.</CardDescription></CardHeader><CardContent className="flex flex-col gap-3"><label htmlFor="accused" className="text-xs text-zinc-400">Select suspect</label><select id="accused" value={accusation} onChange={update_accusation} className="h-10 rounded-md border border-white/10 bg-[#0c1117] px-3 text-sm"><option value="">Choose a suspect</option>{for suspect in case_file.suspects {<option value={suspect.id}>{suspect.name}</option>}}</select><label htmlFor="case-note" className="text-xs text-zinc-400">Evidence-based explanation</label><Textarea id="case-note" value={case_note} onChange={update_note} maxLength={1000} placeholder="Explain the evidence behind your theory" className="border-white/10 bg-[#0c1117] text-zinc-100"/><Button onClick={submit_accusation} disabled={busy} className="bg-amber-400 text-zinc-950">Submit accusation</Button>{verdict != "" and <p className="rounded-lg border border-amber-700/40 bg-amber-950/20 p-4 text-sm leading-6 text-amber-100">{verdict}</p>}</CardContent></Card></aside></div>
            <footer className="border-t border-white/10 pt-4 text-xs text-zinc-600">CASEZERO · FICTIONAL CASE FILE 001 · {case_file.objective}</footer>
        </div>
    </main>;
}
