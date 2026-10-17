def:pub CaseFilePanel(children: any = None) -> JsxElement {
    return <article className="relative rotate-[0.6deg] border border-noir-line bg-noir-raised p-5 shadow-2xl sm:p-8">
        <div className="absolute inset-2 border border-white/[0.04]" />
        {children}
    </article>;
}
