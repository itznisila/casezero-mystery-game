def:pub TabButton(id: str, label: str, active: str, onSelect: any, badge: str = "") -> JsxElement {
    is_active = active == id;
    state_class = "border-primary text-primary" if is_active else "border-transparent text-noir-muted hover:text-noir-ink";
    return <button type="button" role="tab" aria-selected={is_active} onClick={lambda { onSelect(id); }} className={"min-h-11 shrink-0 border-b-2 px-3 text-sm font-medium transition-colors focus-visible:outline-2 focus-visible:outline-offset-[-2px] focus-visible:outline-primary " + state_class}>
        {label}{badge != "" and <span className="ml-2 font-mono text-[10px] text-noir-muted">{badge}</span>}
    </button>;
}

def:pub GameTabs(active: str, onSelect: any, evidence_badge: str = "") -> JsxElement {
    return <nav role="tablist" aria-label="Investigation sections" className="flex gap-1 overflow-x-auto border-b border-noir-line">
        <TabButton id="locations" label="Locations" active={active} onSelect={onSelect} />
        <TabButton id="evidence" label="Evidence" active={active} onSelect={onSelect} badge={evidence_badge} />
        <TabButton id="interviews" label="Interviews" active={active} onSelect={onSelect} />
        <TabButton id="timeline" label="Timeline" active={active} onSelect={onSelect} />
        <TabButton id="theory" label="Theory" active={active} onSelect={onSelect} />
        <TabButton id="advisors" label="Advisors" active={active} onSelect={onSelect} />
        <TabButton id="accuse" label="Accuse" active={active} onSelect={onSelect} />
    </nav>;
}
