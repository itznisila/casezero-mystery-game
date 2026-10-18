def:pub Panel(title: str, subtitle: str = "", children: any = None) -> JsxElement {
    return <section className="border border-noir-line bg-noir-raised p-4 sm:p-5">
        <h2 className="font-serif text-2xl text-noir-ink">{title}</h2>
        {subtitle != "" and <p className="mt-1 text-xs leading-5 text-noir-muted">{subtitle}</p>}
        <div className="mt-4">{children}</div>
    </section>;
}
