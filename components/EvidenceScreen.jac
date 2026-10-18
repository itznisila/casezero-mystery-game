import from "@jac/runtime" { Link, useParams, useNavigate }
sv import from ..lib.casezero_domain { InvestigationActionKind }
sv import from ..services.caseManager { InvestigationSession, InvestigationCommand, InvestigationDossier, get_investigation_session, get_investigation_dossier, submit_investigation_action, reset_missing_prototype_investigation }
sv import from ..services.caseAgents { interview_agent, evidence_analyst_agent, theory_coach_agent, verdict_explainer_agent }


def:pub EvidenceScreen() -> JsxElement {
    has session: InvestigationSession | None = None;
    has dossier: InvestigationDossier | None = None;
    has loading: bool = True;
    has busy: bool = False;
    has error_message: str = "";
    has notice: str = "";
    has selected_suspect: str = "mara";
    has question: str = "";
    has theory_title: str = "";
    has theory_text: str = "";
    has accusation_text: str = "";
    has accused_id: str = "";
    has interview_reply: str = "";
    has analyst_note: str = "";
    has advocate_note: str = "";
    has verdict_note: str = "";
    params = useParams();
    navigate = useNavigate();
    raw_session_id = params["session_id"];
    session_id = str(raw_session_id);

    async can with entry {
        if raw_session_id {
            try {
                session = await get_investigation_session(session_id);
                dossier = await get_investigation_dossier();
                if session is None { error_message = "This investigation session is unavailable. Start a new case from the briefing."; }
            } except Exception { error_message = "The investigation could not be loaded."; }
        } else { error_message = "An investigation session is required."; }
        loading = False;
    }
    def update_question(e: ChangeEvent) { question = e.target.value; }
    def update_title(e: ChangeEvent) { theory_title = e.target.value; }
    def update_theory(e: ChangeEvent) { theory_text = e.target.value; }
    def update_accusation(e: ChangeEvent) { accusation_text = e.target.value; }
    def update_accused(e: ChangeEvent) { accused_id = e.target.value; }

    async def act(kind: InvestigationActionKind, target_id: str | None, content: str, title: str, evidence_ids: list[str], confidence: float) {
        if busy or session is None or session.resolved { return; }
        busy = True;
        error_message = "";
        notice = "";
        try {
            action_id = session_id + "-action-" + str(len(session.actions) + 1);
            command = InvestigationCommand(id=action_id, kind=kind, actor_id="lead-investigator", created_at="21:40", target_id=target_id, evidence_ids=evidence_ids, content=content, title=title, confidence=confidence);
            result = await submit_investigation_action(session_id, command);
            if result.accepted { session = result.session; notice = result.message; }
            else { error_message = result.message; }
        } except Exception { error_message = "The action could not be recorded. Case state is unchanged."; }
        busy = False;
    }
    async def inspect(evidence_id: str) {
        await act(InvestigationActionKind.INSPECT, evidence_id, "", "", [], 0.0);
        if error_message == "" and session is not None { analyst = await evidence_analyst_agent(session.discovered_evidence_ids); analyst_note = analyst.message; }
    }
    async def visit_location(location_id: str) { await act(InvestigationActionKind.VISIT_LOCATION, location_id, "", "", [], 0.0); }
    async def open_timeline { await act(InvestigationActionKind.ACCESS_TIMELINE, None, "", "", [], 0.0); }
    async def ask_suspect {
        if question.strip() == "" or session is None { return; }
        reply = await interview_agent(selected_suspect, question.strip(), session.discovered_evidence_ids);
        await act(InvestigationActionKind.INTERVIEW, selected_suspect, question.strip(), "", reply.citations, 0.0);
        if error_message == "" { interview_reply = reply.message; question = ""; }
    }
    async def save_theory {
        if session is None { return; }
        target = accused_id if accused_id != "" else None;
        await act(InvestigationActionKind.FORM_THEORY, target, theory_text, theory_title, session.discovered_evidence_ids, 0.7);
        if error_message == "" { coach = await theory_coach_agent(theory_text, session.discovered_evidence_ids); advocate_note = coach.message; theory_title = ""; theory_text = ""; }
    }
    async def accuse {
        if session is None { return; }
        current_session = session;
        refs = [e.id for e in current_session.case_record.evidence if (e.id == "E-01" or e.id == "E-03") and e.id in current_session.discovered_evidence_ids];
        verdict = await verdict_explainer_agent(accused_id, refs); verdict_note = verdict.message;
        await act(InvestigationActionKind.ACCUSE, accused_id, accusation_text, "", refs, 0.7);
    }
    async def replay {
        busy = True;
        try {
            fresh_id = "case-001-" + str(new(Date).getTime());
            receipt = await reset_missing_prototype_investigation(fresh_id);
            navigate("/evidence/" + receipt.session_id);
        } except Exception { error_message = "Could not open a fresh investigation."; }
        busy = False;
    }

    if loading { return <main className="min-h-svh bg-noir p-6 text-noir-ink"><section className="mx-auto max-w-6xl animate-pulse"><div className="h-8 w-64 bg-noir-panel"/><div className="mt-6 h-48 border border-noir-line bg-noir-raised"/></section></main>; }
    if session is None or dossier is None { return <main className="min-h-svh bg-noir p-6 text-noir-ink"><section className="mx-auto max-w-3xl border border-destructive/40 bg-noir-raised p-7" role="alert"><h1 className="font-serif text-3xl">Investigation unavailable</h1><p className="mt-3 text-sm text-noir-muted">{error_message}</p><Link to="/briefing" className="mt-5 inline-flex border border-primary px-4 py-3 text-primary">Open a new case</Link></section></main>; }

    suspects = dossier.suspects;
    locations = dossier.locations;
    events = dossier.record.timeline;
    evidence = dossier.evidence;
    discovered_count = len(session.discovered_evidence_ids);
    next_action = "Review the evidence board, then question the suspects.";

    return <main className="min-h-svh bg-noir text-noir-ink">
        <header className="sticky top-0 z-20 border-b border-noir-line bg-noir px-4 py-3 sm:px-6"><div className="mx-auto flex max-w-7xl flex-wrap items-center justify-between gap-3"><Link to="/" className="font-semibold tracking-[0.18em] text-primary">CASEZERO</Link><span className="font-mono text-xs text-noir-muted">CASE 001 · {str(discovered_count)} / 4 LEADS</span></div></header>
        <div className="mx-auto flex max-w-7xl flex-col gap-5 px-4 py-6 sm:px-6">
            <section className="border-b border-noir-line pb-5"><p className="font-mono text-[10px] tracking-[0.2em] text-primary">NORTHSTAR RESEARCH FACILITY</p><h1 className="mt-2 font-serif text-3xl sm:text-4xl">{dossier.record.title}</h1><p className="mt-2 max-w-3xl text-sm leading-6 text-noir-muted">{dossier.briefing.briefing}</p></section>
            {error_message != "" and <p role="alert" className="border border-destructive/40 bg-destructive/10 p-3 text-sm">{error_message}</p>}
            {notice != "" and <p role="status" className="border border-primary/30 bg-primary/5 p-3 text-sm">{notice}</p>}
            {session.resolved and <section className="border border-primary/40 bg-noir-raised p-5"><p className="font-mono text-xs tracking-[0.18em] text-primary">CASE CLOSED · OFFICIAL RESULT</p><h2 className="mt-3 font-serif text-3xl">The accusation is upheld</h2>{session.accusation is not None and <p className="mt-4 text-sm leading-7 text-noir-muted">{session.accusation.explanation}</p>}<button type="button" onClick={replay} disabled={busy} className="mt-5 border border-primary bg-primary px-5 py-3 font-semibold text-primary-foreground">Open a new investigation</button></section>}
            <div className="grid gap-5 xl:grid-cols-[minmax(0,1.65fr)_minmax(300px,0.85fr)]">
                <div className="flex min-w-0 flex-col gap-5">
                    <section className="border border-noir-line bg-noir-raised p-4 sm:p-5"><h2 className="font-serif text-2xl">Facility locations</h2><p className="mt-1 text-xs text-noir-muted">Visit a location to record it in your investigation.</p><div className="mt-4 grid gap-3 sm:grid-cols-2 lg:grid-cols-3">{for location in locations {<article key={location.id} className="flex flex-col border border-noir-line bg-noir p-4"><h3 className="font-medium">{location.name}</h3><p className="mt-2 flex-1 text-xs leading-5 text-noir-muted">{location.description}</p><button type="button" disabled={busy or session.resolved or location.id in session.visited_location_ids} onClick={lambda { visit_location(location.id); }} className="mt-4 min-h-10 border border-noir-line px-3 text-xs disabled:opacity-50">{"Visited" if location.id in session.visited_location_ids else "Visit location"}</button></article>}}</div></section>
                    <section className="border border-noir-line bg-noir-raised p-4 sm:p-5"><h2 className="font-serif text-2xl">Evidence board</h2><p className="mt-1 text-xs text-noir-muted">Records are revealed after an inspection.</p><div className="mt-4 grid gap-3 sm:grid-cols-2">{for item in evidence {if item.id in [ev.id for ev in session.case_record.evidence] {<article key={item.id} className="border border-noir-line bg-noir p-4"><p className="font-mono text-[10px] text-primary">{item.id} · {item.discovered_at}</p><h3 className="mt-2 font-medium">{item.title}</h3><p className="mt-2 text-xs leading-5 text-noir-muted">{item.summary}</p>{item.id in session.discovered_evidence_ids and <p className="mt-3 border-l border-primary/50 pl-3 text-xs leading-5">{item.detail}</p>}<button type="button" disabled={busy or session.resolved or item.id in session.discovered_evidence_ids} onClick={lambda { inspect(item.id); }} className="mt-4 min-h-10 border border-primary/50 px-3 text-xs text-primary disabled:opacity-50">{"Secured" if item.id in session.discovered_evidence_ids else "Inspect evidence"}</button></article>}}}</div>{discovered_count == 0 and <p className="mt-4 border border-dashed border-noir-line p-4 text-center text-xs text-noir-muted">No evidence secured yet. Start with the archive access log.</p>}</section>
                    <section className="border border-noir-line bg-noir-raised p-4 sm:p-5"><h2 className="font-serif text-2xl">Interview room</h2><p className="mt-1 text-xs text-noir-muted">Ask a suspect. Responses reference established case facts.</p><div className="mt-4 flex flex-wrap gap-2">{for suspect in suspects {<button key={suspect.id} type="button" onClick={lambda { selected_suspect = suspect.id; }} className="min-h-10 border border-noir-line px-3 text-xs hover:border-primary">{suspect.name}</button>}}</div>{for suspect in suspects {if selected_suspect == suspect.id {<article key={suspect.id} className="mt-4 border border-noir-line bg-noir p-4"><p className="font-mono text-[10px] text-primary">{suspect.role}</p><h3 className="mt-1 font-serif text-xl">{suspect.name}</h3><p className="mt-3 text-sm leading-6 text-noir-muted">{suspect.profile}</p><div className="mt-4 grid gap-3 sm:grid-cols-3"><p className="text-xs leading-5 text-noir-muted"><b className="text-primary">MOTIVE</b><br/>{suspect.motive}</p><p className="text-xs leading-5 text-noir-muted"><b className="text-primary">ALIBI</b><br/>{suspect.alibi}</p><p className="text-xs leading-5 text-noir-muted"><b className="text-primary">OPPORTUNITY</b><br/>{suspect.opportunity}</p></div></article>}}}<label htmlFor="interview-question" className="mt-4 block text-xs text-noir-muted">Question for suspect</label><div className="mt-2 flex flex-col gap-2 sm:flex-row"><input id="interview-question" value={question} onChange={update_question} maxLength={500} placeholder="Ask about the 21:14 archive entry" className="min-h-11 min-w-0 flex-1 border border-noir-line bg-noir px-3 text-sm"/><button type="button" onClick={ask_suspect} disabled={busy or session.resolved or question.strip() == ""} className="min-h-11 border border-primary bg-primary px-4 text-sm font-semibold text-primary-foreground disabled:opacity-50">Ask suspect</button></div>{interview_reply != "" and <p className="mt-4 border-l-2 border-primary bg-noir p-4 text-sm leading-6">{interview_reply}</p>}</section>
                    <section className="border border-noir-line bg-noir-raised p-4 sm:p-5"><h2 className="font-serif text-2xl">Build a theory</h2><p className="mt-1 text-xs text-noir-muted">Record reasoning using evidence secured in this session.</p><label htmlFor="theory-title" className="mt-4 block text-xs text-noir-muted">Theory title</label><input id="theory-title" value={theory_title} onChange={update_title} maxLength={120} placeholder="A route prepared in advance" className="mt-2 min-h-10 w-full border border-noir-line bg-noir px-3 text-sm"/><label htmlFor="theory-detail" className="mt-3 block text-xs text-noir-muted">Explanation</label><textarea id="theory-detail" value={theory_text} onChange={update_theory} maxLength={1000} rows={3} placeholder="Connect evidence and identify what remains uncertain." className="mt-2 w-full border border-noir-line bg-noir px-3 py-2 text-sm"/><button type="button" onClick={save_theory} disabled={busy or session.resolved or theory_title.strip() == "" or theory_text.strip() == ""} className="mt-3 min-h-11 border border-primary/50 px-4 text-sm text-primary disabled:opacity-50">Record theory</button>{for theory in session.theories {<article key={theory.id} className="mt-4 border border-noir-line bg-noir p-4"><h3 className="font-medium">{theory.title}</h3><p className="mt-2 text-sm leading-6 text-noir-muted">{theory.summary}</p><p className="mt-2 font-mono text-[10px] text-primary">CITED · {", ".join(theory.evidence_ids)}</p></article>}}{advocate_note != "" and <p className="mt-4 border-l-2 border-primary/50 p-3 text-sm leading-6 text-noir-muted"><b className="text-primary">DEVIL'S ADVOCATE</b> · {advocate_note}</p>}</section>
                </div>
                <aside className="flex min-w-0 flex-col gap-5">
                    <section className="border border-primary/30 bg-[#171811] p-4 sm:p-5"><h2 className="font-serif text-xl">Lead detective</h2><p className="mt-3 text-sm leading-6">{next_action}</p><p className="mt-3 border-t border-noir-line pt-3 text-xs leading-5 text-noir-muted">Next lead · Compare secured records with the suspect accounts.</p><p className="mt-3 font-mono text-[9px] text-primary">RULES-BASED · VERIFIED FACTS</p></section>
                    <section className="border border-noir-line bg-noir-raised p-4 sm:p-5"><div className="flex flex-wrap items-center justify-between gap-2"><h2 className="font-serif text-xl">Official timeline</h2><button type="button" onClick={open_timeline} disabled={busy or session.timeline_accessed or session.resolved} className="min-h-9 border border-noir-line px-3 text-xs disabled:opacity-50">{"Timeline opened" if session.timeline_accessed else "Open timeline"}</button></div><ol className="mt-4 flex flex-col gap-4">{for event in events {<li key={event.id} className="border-l border-primary/50 pl-3"><span className="font-mono text-[10px] text-primary">{event.occurred_at}</span><p className="mt-1 text-xs leading-5 text-noir-muted">{event.description}</p>{len(event.evidence_ids) > 0 and <p className="mt-1 font-mono text-[9px] text-noir-muted">RECORD · {", ".join(event.evidence_ids)}</p>}</li>}}</ol></section>
                    <section className="border border-noir-line bg-noir-raised p-4 sm:p-5"><h2 className="font-serif text-xl">Agent activity</h2><p className="mt-2 text-xs leading-5 text-noir-muted">Specialists advise from verified data. The case engine owns evidence and outcomes.</p><div className="mt-4 flex flex-col gap-3"><article className="border border-noir-line bg-noir p-3"><p className="font-mono text-[9px] text-primary">LEAD DETECTIVE</p><p className="mt-2 text-xs leading-5 text-noir-muted">{next_action}</p></article><article className="border border-noir-line bg-noir p-3"><p className="font-mono text-[9px] text-primary">EVIDENCE ANALYST</p><p className="mt-2 text-xs leading-5 text-noir-muted">{analyst_note if analyst_note != "" else "Awaiting secured records to compare."}</p></article><article className="border border-noir-line bg-noir p-3"><p className="font-mono text-[9px] text-primary">SUSPECT INTERVIEWER</p><p className="mt-2 text-xs leading-5 text-noir-muted">{interview_reply if interview_reply != "" else "Ready to test a suspect account."}</p></article><article className="border border-noir-line bg-noir p-3"><p className="font-mono text-[9px] text-primary">DEVIL'S ADVOCATE</p><p className="mt-2 text-xs leading-5 text-noir-muted">{advocate_note if advocate_note != "" else "Ready to challenge a theory."}</p></article></div><p className="mt-3 border-t border-noir-line pt-3 font-mono text-[9px] leading-4 text-noir-muted">RULES-BASED ADVISORS · LIVE MODEL NOT CONFIGURED<br/>Add OPENAI_API_KEY in JacHammer Settings to enable optional model-backed advice.</p></section>
                    <section className="border border-primary/30 bg-noir-raised p-4 sm:p-5"><h2 className="font-serif text-xl">Final accusation</h2><p className="mt-2 text-xs leading-5 text-noir-muted">Secure E-01 and E-03 before submitting. The case engine determines the outcome.</p><label htmlFor="accused-suspect" className="mt-4 block text-xs text-noir-muted">Suspect</label><select id="accused-suspect" value={accused_id} onChange={update_accused} disabled={session.resolved} className="mt-2 min-h-11 w-full border border-noir-line bg-noir px-3 text-sm"><option value="">Choose a suspect</option>{for suspect in suspects {<option key={suspect.id} value={suspect.id}>{suspect.name}</option>}}</select><label htmlFor="accusation-reason" className="mt-4 block text-xs text-noir-muted">Your reasoning</label><textarea id="accusation-reason" value={accusation_text} onChange={update_accusation} maxLength={1000} rows={4} placeholder="Explain how the verified records support your conclusion." className="mt-2 w-full border border-noir-line bg-noir px-3 py-2 text-sm"/><button type="button" onClick={accuse} disabled={busy or session.resolved or accused_id == "" or accusation_text.strip() == "" or not ("E-01" in session.discovered_evidence_ids) or not ("E-03" in session.discovered_evidence_ids)} className="mt-4 min-h-11 w-full border border-primary bg-primary px-4 text-sm font-semibold text-primary-foreground disabled:opacity-50">Submit accusation</button>{verdict_note != "" and <p className="mt-3 border-l border-primary/50 pl-3 text-xs leading-5 text-noir-muted">{verdict_note}</p>}{session.accusation is not None and <p role="status" className="mt-4 border border-primary/30 p-3 text-sm">{session.accusation.message}</p>}</section>
                </aside>
            </div>
        </div>
    </main>;
}
