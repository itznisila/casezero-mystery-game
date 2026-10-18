def:pub Notice(message: str, tone: str = "info", onDismiss: any = None) -> JsxElement {
    tone_class = "border-red-300/40 bg-red-500/10" if tone == "error" else "border-primary/40 bg-primary/10";
    live = "alert" if tone == "error" else "status";
    return <div role={live} className={"flex items-start justify-between gap-3 border p-3 text-sm leading-6 text-noir-ink " + tone_class}>
        <p>{message}</p>
        <button type="button" onClick={onDismiss} aria-label="Dismiss message" className="min-h-6 min-w-6 text-noir-muted hover:text-noir-ink focus-visible:outline-2 focus-visible:outline-primary">×</button>
    </div>;
}
