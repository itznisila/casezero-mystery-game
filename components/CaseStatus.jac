def:pub CaseStatus(label: str, tone: str = "open") -> JsxElement {
    tone_class = "border-red-300/30 text-red-200/80" if tone == "unresolved" else "border-primary/35 text-primary";
    return <span role="status" className={"shrink-0 border px-2 py-1 font-mono text-[9px] tracking-[0.18em] " + tone_class}>{label}</span>;
}
