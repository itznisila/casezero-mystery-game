def:pub CaseActionButton(label: str, onClick: Callable[[MouseEvent], None], children: any = None) -> JsxElement {
    return <button type="button" onClick={onClick} className="h-12 w-full rounded-none border border-primary bg-primary px-7 font-semibold tracking-wide text-primary-foreground shadow-[0_0_32px_rgba(229,190,105,0.12)] transition-colors hover:bg-primary/90 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-primary sm:w-auto">
        {label}<span aria-hidden="true" className="ml-3">{children}</span>
    </button>;
}
