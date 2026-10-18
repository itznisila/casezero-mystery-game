import from "@jac/runtime" { Link, useParams }
import from .Notice { Notice }
import from .GameTabs { GameTabs }
import from .LocationsPanel { LocationsPanel }
import from .EvidencePanel { EvidencePanel }
import from .InterviewPanel { InterviewPanel }
import from .TimelinePanel { TimelinePanel }
import from .TheoryPanel { TheoryPanel }
import from .AdvisorsPanel { AdvisorsPanel }
import from .AccusationPanel { AccusationPanel }
import from .VerdictPanel { VerdictPanel }
sv import from ..services.gameApi {
    CaseBoard, ActionResult, get_case_board, visit_location, secure_evidence,
    open_timeline, ask_suspect, ask_advisor, submit_theory, file_accusation, restart_investigation
}

def:pub InvestigationRoom() -> JsxElement {
    has board: CaseBoard | None = None;
    has loading: bool = True;
    has busy: bool = False;
    has error_message: str = "";
    has notice: str = "";
    has tab: str = "locations";
    has advice_agent: str = "";
    has advice_text: str = "";
    has advice_mode: str = "";
    has advice_steps: list[str] = [];
    has challenge: str = "";
    params = useParams();
    raw_session_id = params["session_id"];
    session_id = str(raw_session_id);

    async can with entry {
        if raw_session_id {
            try {
                board = await get_case_board(session_id);
            } except Exception {
                error_message = "This investigation could not be loaded. Open the briefing to start a new case.";
            }
        } else {
            error_message = "An investigation session is required.";
        }
        loading = False;
    }

    def select_tab(tab_id: str) { tab = tab_id; }
    def clear_error(e: MouseEvent) { error_message = ""; }
    def clear_notice(e: MouseEvent) { notice = ""; }

    async def refresh() {
        try {
            board = await get_case_board(session_id);
        } except Exception {
            error_message = "The case file could not be refreshed. Your last action may still have been saved.";
        }
    }
    def report(result: ActionResult) {
        if result.accepted {
            notice = result.message;
            error_message = "";
        } else {
            error_message = result.message;
            notice = "";
        }
    }
    async def do_visit(location_id: str) {
        if busy { return; }
        busy = True;
        try {
            report(await visit_location(session_id, location_id));
            await refresh();
        } except Exception {
            error_message = "That action could not be completed. Your case is unchanged.";
        }
        busy = False;
    }
    async def do_secure(evidence_id: str) {
        if busy { return; }
        busy = True;
        try {
            report(await secure_evidence(session_id, evidence_id));
            await refresh();
        } except Exception {
            error_message = "That action could not be completed. Your case is unchanged.";
        }
        busy = False;
    }
    async def do_open_timeline(e: MouseEvent) {
        if busy { return; }
        busy = True;
        try {
            report(await open_timeline(session_id));
            await refresh();
        } except Exception {
            error_message = "The timeline could not be opened.";
        }
        busy = False;
    }
    async def do_ask(suspect_id: str, question: str, evidence_ids: list[str]) -> bool {
        if busy { return False; }
        busy = True;
        ok = False;
        try {
            turn = await ask_suspect(session_id, suspect_id, question, evidence_ids);
            if turn.accepted {
                ok = True;
                error_message = "";
                notice = "Answer recorded.";
                if len(turn.new_contradictions) > 0 { notice = "Contradiction logged: " + ", ".join(turn.new_contradictions); }
            } else {
                error_message = turn.message;
                notice = "";
            }
            await refresh();
        } except Exception {
            error_message = "The question could not be asked. Your case is unchanged.";
        }
        busy = False;
        return ok;
    }
    async def do_advisor(role: str) {
        if busy { return; }
        busy = True;
        try {
            reply = await ask_advisor(session_id, role, "");
            advice_agent = reply.agent;
            advice_text = reply.message;
            advice_mode = reply.mode;
            advice_steps = reply.next_steps;
            error_message = "";
            await refresh();
        } except Exception {
            error_message = "The advisor could not answer right now.";
        }
        busy = False;
    }
    async def do_theory(title: str, summary: str, evidence_ids: list[str], suspect_id: str, confidence: float) -> bool {
        if busy { return False; }
        busy = True;
        ok = False;
        try {
            result = await submit_theory(session_id, title, summary, evidence_ids, suspect_id, confidence);
            report(result);
            if result.accepted {
                ok = True;
                challenge = result.advisor_message;
            }
            await refresh();
        } except Exception {
            error_message = "The theory could not be recorded. Your case is unchanged.";
        }
        busy = False;
        return ok;
    }
    async def do_accuse(suspect_id: str, explanation: str, evidence_ids: list[str]) -> bool {
        if busy { return False; }
        busy = True;
        ok = False;
        try {
            result = await file_accusation(session_id, suspect_id, explanation, evidence_ids);
            report(result);
            ok = result.accepted;
            await refresh();
        } except Exception {
            error_message = "The accusation could not be filed. Your case is unchanged.";
        }
        busy = False;
        return ok;
    }
    async def do_replay(e: MouseEvent) {
        if busy { return; }
        busy = True;
        try {
            fresh_id = "case-001-" + str(new(Date).getTime());
            receipt = await restart_investigation(fresh_id);
            window.location.href = "/case/" + receipt.session_id;
        } except Exception {
            error_message = "A new investigation could not be opened.";
            busy = False;
        }
    }

    if loading {
        return <main className="min-h-svh bg-noir p-6 text-noir-ink"><section className="mx-auto max-w-6xl animate-pulse" aria-label="Loading investigation"><div className="h-8 w-64 bg-noir-panel" /><div className="mt-6 h-12 border border-noir-line bg-noir-raised" /><div className="mt-4 h-64 border border-noir-line bg-noir-raised" /></section></main>;
    }
    if board is None {
        return <main className="min-h-svh bg-noir p-6 text-noir-ink"><section className="mx-auto max-w-3xl border border-destructive/40 bg-noir-raised p-7" role="alert"><p className="font-mono text-xs tracking-[0.16em] text-destructive">INVESTIGATION UNAVAILABLE</p><h1 className="mt-4 font-serif text-3xl">This case file could not be opened</h1><p className="mt-4 text-sm leading-6 text-noir-muted">{error_message}</p><Link to="/briefing" className="mt-6 inline-flex min-h-11 items-center border border-primary px-5 text-sm font-semibold text-primary hover:bg-primary hover:text-primary-foreground">Open the briefing</Link></section></main>;
    }

    verdict_name = "";
    verdict_message = "";
    verdict_text = "";
    verdict_score = 0;
    verdict_refs: list[str] = [];
    result_record = board.accusation;
    if result_record is not None and board.resolved {
        verdict_message = result_record.message;
        verdict_text = result_record.explanation;
        verdict_score = result_record.score;
        verdict_refs = result_record.evidence_ids;
        for person in board.suspects {
            if person.id == result_record.suspect_id { verdict_name = person.name; }
        }
    }

    return <main className="min-h-svh bg-noir text-noir-ink">
        <header className="sticky top-0 z-20 border-b border-noir-line bg-noir px-4 py-3 sm:px-6">
            <div className="mx-auto flex max-w-7xl flex-wrap items-center justify-between gap-3">
                <Link to="/" className="font-semibold tracking-[0.18em] text-primary focus-visible:outline-2 focus-visible:outline-primary">CASEZERO</Link>
                <div className="flex min-w-48 flex-1 items-center gap-3 sm:max-w-xs" aria-label={"Case progress " + str(board.progress) + " percent"}>
                    <span className="font-mono text-[10px] tracking-[0.14em] text-noir-muted">PROGRESS</span>
                    <div className="h-1.5 flex-1 bg-noir-panel"><div className="h-full bg-primary transition-all" style={{"width": str(board.progress) + "%"}} /></div>
                    <span className="font-mono text-[10px] text-noir-muted">{str(board.progress)}%</span>
                </div>
            </div>
        </header>
        <div className="mx-auto flex max-w-7xl flex-col gap-5 px-4 py-6 sm:px-6">
            <section className="border-b border-noir-line pb-5">
                <p className="font-mono text-[10px] tracking-[0.2em] text-primary">NORTHSTAR RESEARCH FACILITY · CASE 001</p>
                <h1 className="mt-2 font-serif text-3xl sm:text-4xl">The Missing Prototype</h1>
                <p className="mt-2 max-w-3xl text-sm leading-6 text-noir-muted">Find out how the Helix prototype left a locked archive. Secure records, test every account against them, and name the person responsible.</p>
            </section>
            {error_message != "" and <Notice message={error_message} tone="error" onDismiss={clear_error} />}
            {notice != "" and <Notice message={notice} tone="info" onDismiss={clear_notice} />}
            {board.resolved and <VerdictPanel suspect_name={verdict_name} message={verdict_message} explanation={verdict_text} score={verdict_score} evidence_ids={verdict_refs} busy={busy} onReplay={do_replay} />}
            <GameTabs active={tab} onSelect={select_tab} evidence_badge={str(len(board.evidence)) + "/" + str(board.evidence_total)} />
            {tab == "locations" and <LocationsPanel locations={board.locations} busy={busy} resolved={board.resolved} onVisit={do_visit} onSecure={do_secure} />}
            {tab == "evidence" and <EvidencePanel evidence={board.evidence} total={board.evidence_total} statements={board.statements} suspects={board.suspects} />}
            {tab == "interviews" and <InterviewPanel suspects={board.suspects} transcript={board.transcript} evidence={board.evidence} busy={busy} resolved={board.resolved} onAsk={do_ask} />}
            {tab == "timeline" and <TimelinePanel timeline_open={board.timeline_open} timeline={board.timeline} contradictions={board.contradictions} leads={board.leads} busy={busy} resolved={board.resolved} onOpen={do_open_timeline} />}
            {tab == "theory" and <TheoryPanel evidence={board.evidence} suspects={board.suspects} theories={board.theories} challenge={challenge} busy={busy} resolved={board.resolved} onSubmit={do_theory} />}
            {tab == "advisors" and <AdvisorsPanel agent_log={board.agent_log} latest_agent={advice_agent} latest_text={advice_text} latest_mode={advice_mode} latest_steps={advice_steps} busy={busy} onAsk={do_advisor} />}
            {tab == "accuse" and <AccusationPanel suspects={board.suspects} evidence={board.evidence} busy={busy} resolved={board.resolved} onAccuse={do_accuse} />}
        </div>
    </main>;
}
