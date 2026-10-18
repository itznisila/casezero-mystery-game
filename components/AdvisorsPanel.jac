import from .Panel { Panel }
sv import from ..services.gameApi { AgentLogEntry }

def:pub AdvisorsPanel(agent_log: list[AgentLogEntry], latest_agent: str, latest_text: str, latest_mode: str, latest_steps: list[str], busy: bool, onAsk: any) -> JsxElement {
    newest_first = [agent_log[len(agent_log) - 1 - i] for i in range(len(agent_log))];

    def mode_label(mode: str) -> str {
        if mode == "rules-only" { return "RULES-ONLY"; }
        return mode.upper();
    }

    return <div className="flex flex-col gap-5">
        <Panel title="Your advisors" subtitle="Four specialists advise from verified case facts. They never decide the verdict.">
            <div className="grid gap-3 sm:grid-cols-2">
                <article className="border border-noir-line bg-noir p-4">
                    <h3 className="font-medium text-noir-ink">Lead Detective</h3>
                    <p className="mt-1 text-xs leading-5 text-noir-muted">Points to the next open lead and the gap in your case.</p>
                    <button type="button" disabled={busy} onClick={lambda { onAsk("lead"); }} className="mt-3 min-h-10 border border-primary px-4 text-sm font-semibold text-primary hover:bg-primary hover:text-primary-foreground disabled:opacity-50">Ask for guidance</button>
                </article>
                <article className="border border-noir-line bg-noir p-4">
                    <h3 className="font-medium text-noir-ink">Evidence Analyst</h3>
                    <p className="mt-1 text-xs leading-5 text-noir-muted">Explains what your secured records do and do not prove.</p>
                    <button type="button" disabled={busy} onClick={lambda { onAsk("evidence"); }} className="mt-3 min-h-10 border border-primary px-4 text-sm font-semibold text-primary hover:bg-primary hover:text-primary-foreground disabled:opacity-50">Analyze my evidence</button>
                </article>
                <article className="border border-noir-line bg-noir p-4">
                    <h3 className="font-medium text-noir-ink">Suspect Interviewer</h3>
                    <p className="mt-1 text-xs leading-5 text-noir-muted">Voices each suspect's answers. Find it in the Interviews tab.</p>
                </article>
                <article className="border border-noir-line bg-noir p-4">
                    <h3 className="font-medium text-noir-ink">Devil's Advocate</h3>
                    <p className="mt-1 text-xs leading-5 text-noir-muted">Challenges your theory. Find it in the Theory tab.</p>
                </article>
            </div>
        </Panel>
        {latest_text != "" and <section className="border border-primary/40 bg-primary/5 p-4 sm:p-5" aria-live="polite">
            <p className="font-mono text-[10px] tracking-[0.16em] text-primary">{latest_agent.upper()} · {mode_label(latest_mode)}</p>
            <p className="mt-2 text-sm leading-6 text-noir-ink">{latest_text}</p>
            {len(latest_steps) > 0 and <ul className="mt-3 flex flex-col gap-1">
                {for step in latest_steps {<li key={step} className="text-xs text-noir-muted">→ {step}</li>}}
            </ul>}
        </section>}
        <Panel title="Investigation history" subtitle="Every advisor reply and interview answer in this case, newest first.">
            {len(newest_first) == 0 and <p className="text-sm text-noir-muted">No agent activity yet.</p>}
            <ul className="flex flex-col gap-3">
                {for entry in newest_first {<li key={entry.id} className="border-l-2 border-primary/40 pl-3">
                    <p className="font-mono text-[10px] tracking-[0.14em] text-primary/80">{entry.agent.upper()} · {mode_label(entry.mode)}</p>
                    <p className="mt-1 text-sm leading-6 text-noir-muted">{entry.summary}</p>
                </li>}}
            </ul>
        </Panel>
    </div>;
}
