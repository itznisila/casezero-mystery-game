"""The build splash — what the preview shows before the app exists.

Two states:

  * No prompt (created from the template gallery) -> the sparkles message.
  * With a prompt -> the JacBuilder splash: the user's own words echoed back,
    plus a wireframe skeleton of the KIND of app they asked for.

`BUILD_PROMPT` is a sentinel the IDE rewrites at create time
(`project_manager._apply_build_prompt_to_template`). It finds this file by
name and that string by value -- do not rename either.

The skeleton is a guess keyed off words in the prompt. That is deliberate: a
shimmer reads as "loading", never as a promise, so a rough shape costs
nothing when it is wrong and orients the user when it is right. Prompts that
match nothing fall back to a neutral app shell.

The whole splash disappears the moment JacCoder rewrites this file. Keep it
that way -- a skeleton that outlives the real UI is worse than no skeleton.

Two client-Jac constraints shaped this file, both worth knowing before you
edit it:
  * `.map(...)` over a literal list trips the checker ("list has no attribute
    map"), so repeated bars are written out longhand.
  * Use Python string methods (`.lower()`, `x in y`), not the JS ones --
    `.toLowerCase()` / `.indexOf()` do not type-check.
"""

cl import ".styles.global.css";
cl import from ".components.ui.skeleton" { Skeleton }

glob BUILD_PROMPT: str = "# Build CaseZero — An Agentic AI Mystery Investigation Game  ## 1. Project Overview  Build a complete, polished, full-stack web application called **CaseZero: The Agentic Mystery Room**.  CaseZero is an interactive detective game in which players investigate fictional crimes by examining evidence, interviewing suspects, discovering contradictions, and making accusations. The core feature is a team of collaborating AI agents that independently investigate the case, use tools, evaluate evidence, and adapt their next actions based on discoveries.  This must be a genuinely agentic AI application, not simply a chatbot with a detective-themed interface.  **Technology requirements:** - Use **Jac as the primary programming language (include that the GitHub code programming language percentage must be at least above 80%,)** for the application's backend and agentic workflows. - Use the Jac web application framework and its supported frontend capabilities. - Use Jac's AI integration capabilities, including byLLM where appropriate. - Use an external AI model through an API key. - Build a working, responsive web application with a professional user interface. - Organize the source code so it can be committed to a GitHub repository. - Include complete, working code for every implemented feature and every development commit.  Do not merely generate a mockup, static interface, or frontend demonstration. Build functional application logic and connect the interface to the backend and AI agents.  ## 2. Core Game Concept  The player becomes the lead investigator in a fictional mystery.  The initial case is called **The Missing Prototype**.  A valuable prototype has disappeared from a research laboratory. Three suspects were connected to the laboratory on the evening of the incident. Each suspect has a background, possible motive, alibi, private information, and a unique personality.  The player must investigate the incident, collect evidence, interview suspects, compare statements aga";

# The preview iframe cannot see the IDE's theme, so the sandbox proxy stamps it
# on a `preview_theme` cookie at /__auth. Applied during render, not from an
# effect -- an effect runs after the first paint and the splash flashes white.
cl def _applyPreviewTheme() -> None {
    isDark = False;
    for part in document.cookie.split(";") {
        if part.strip() == "preview_theme=dark" {
            isDark = True;
        }
    }
    if isDark {
        document.documentElement.classList.add("dark");
    }
}

# keyword -> layout, first match wins.
glob _HINTS: list[list[str]] = [
    ["dashboard", "dashboard"], ["admin", "dashboard"], ["analytics", "dashboard"],
    ["metrics", "dashboard"], ["chart", "dashboard"], ["crm", "dashboard"],
    ["tracker", "dashboard"], ["report", "dashboard"],
    ["landing", "landing"], ["marketing", "landing"], ["waitlist", "landing"],
    ["saas", "landing"], ["homepage", "landing"], ["portfolio", "landing"],
    ["pricing", "landing"],
    ["chat", "chat"], ["assistant", "chat"], ["messaging", "chat"],
    ["inbox", "chat"], ["bot", "chat"],
    ["shop", "shop"], ["store", "shop"], ["ecommerce", "shop"],
    ["commerce", "shop"], ["product", "shop"], ["cart", "shop"],
    ["blog", "blog"], ["docs", "blog"], ["article", "blog"],
    ["news", "blog"], ["documentation", "blog"]
];

glob _PANEL: str = "rounded-xl border border-border bg-card";


cl def:pub DashboardSkeleton() -> JsxElement {
    return <div className="flex w-full gap-4">
        <div className={"hidden md:flex w-44 shrink-0 flex-col gap-3 self-stretch pt-5 pb-5 pl-4 pr-4 " + _PANEL}>
            <Skeleton className="h-5 w-24" />
            <Skeleton className="h-3.5 w-full" />
            <Skeleton className="h-3.5 w-full" />
            <Skeleton className="h-3.5 w-full" />
            <Skeleton className="h-3.5 w-2/3" />
        </div>
        <div className="flex flex-1 flex-col gap-4">
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
                <div className={"flex flex-col gap-3 pt-4 pb-4 pl-4 pr-4 " + _PANEL}>
                    <Skeleton className="h-3 w-16" />
                    <Skeleton className="h-7 w-14" />
                </div>
                <div className={"flex flex-col gap-3 pt-4 pb-4 pl-4 pr-4 " + _PANEL}>
                    <Skeleton className="h-3 w-16" />
                    <Skeleton className="h-7 w-14" />
                </div>
                <div className={"flex flex-col gap-3 pt-4 pb-4 pl-4 pr-4 " + _PANEL}>
                    <Skeleton className="h-3 w-16" />
                    <Skeleton className="h-7 w-14" />
                </div>
            </div>
            <div className={"flex h-56 items-end gap-2 pt-4 pb-4 pl-4 pr-4 " + _PANEL}>
                <Skeleton className="h-2/5 flex-1" />
                <Skeleton className="h-3/4 flex-1" />
                <Skeleton className="h-1/2 flex-1" />
                <Skeleton className="h-5/6 flex-1" />
                <Skeleton className="h-1/3 flex-1" />
                <Skeleton className="h-2/3 flex-1" />
                <Skeleton className="h-3/4 flex-1" />
            </div>
            <div className={"flex flex-col gap-3 pt-4 pb-4 pl-4 pr-4 " + _PANEL}>
                <div className="flex items-center gap-4">
                    <Skeleton className="h-3.5 w-32" />
                    <Skeleton className="ml-auto h-3.5 w-20" />
                    <Skeleton className="h-3.5 w-16" />
                </div>
                <div className="flex items-center gap-4">
                    <Skeleton className="h-3.5 w-40" />
                    <Skeleton className="ml-auto h-3.5 w-20" />
                    <Skeleton className="h-3.5 w-16" />
                </div>
                <div className="flex items-center gap-4">
                    <Skeleton className="h-3.5 w-28" />
                    <Skeleton className="ml-auto h-3.5 w-20" />
                    <Skeleton className="h-3.5 w-16" />
                </div>
                <div className="flex items-center gap-4">
                    <Skeleton className="h-3.5 w-36" />
                    <Skeleton className="ml-auto h-3.5 w-20" />
                    <Skeleton className="h-3.5 w-16" />
                </div>
                <div className="flex items-center gap-4">
                    <Skeleton className="h-3.5 w-24" />
                    <Skeleton className="ml-auto h-3.5 w-20" />
                    <Skeleton className="h-3.5 w-16" />
                </div>
            </div>
        </div>
    </div>;
}


cl def:pub LandingSkeleton() -> JsxElement {
    return <div className="flex w-full flex-col gap-5">
        <div className={"flex items-center gap-4 pt-3 pb-3 pl-4 pr-4 " + _PANEL}>
            <Skeleton className="h-5 w-24" />
            <div className="ml-auto flex gap-3">
                <Skeleton className="h-3.5 w-14" />
                <Skeleton className="h-3.5 w-14" />
                <Skeleton className="h-3.5 w-14" />
            </div>
        </div>
        <div className="flex flex-col items-center gap-4 pt-8 pb-8">
            <Skeleton className="h-9 w-3/4 max-w-lg" />
            <Skeleton className="h-9 w-1/2 max-w-sm" />
            <Skeleton className="mt-2 h-4 w-2/3 max-w-md" />
            <div className="mt-3 flex gap-3">
                <Skeleton className="h-10 w-32 rounded-lg bg-primary/25" />
                <Skeleton className="h-10 w-28 rounded-lg" />
            </div>
        </div>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            <div className={"flex flex-col gap-3 pt-5 pb-5 pl-4 pr-4 " + _PANEL}>
                <Skeleton className="size-9 rounded-lg bg-primary/20" />
                <Skeleton className="h-4 w-24" />
                <Skeleton className="h-3 w-full" />
            </div>
            <div className={"flex flex-col gap-3 pt-5 pb-5 pl-4 pr-4 " + _PANEL}>
                <Skeleton className="size-9 rounded-lg bg-primary/20" />
                <Skeleton className="h-4 w-24" />
                <Skeleton className="h-3 w-full" />
            </div>
            <div className={"flex flex-col gap-3 pt-5 pb-5 pl-4 pr-4 " + _PANEL}>
                <Skeleton className="size-9 rounded-lg bg-primary/20" />
                <Skeleton className="h-4 w-24" />
                <Skeleton className="h-3 w-full" />
            </div>
        </div>
    </div>;
}


cl def:pub ChatSkeleton() -> JsxElement {
    return <div className={"flex w-full flex-col gap-4 pt-4 pb-4 pl-4 pr-4 " + _PANEL}>
        <div className="flex items-center gap-3">
            <Skeleton className="size-9 rounded-full" />
            <Skeleton className="h-4 w-28" />
        </div>
        <div className="flex flex-col gap-3">
            <Skeleton className="h-12 w-3/5 rounded-2xl" />
            <Skeleton className="h-14 w-2/3 self-end rounded-2xl bg-primary/20" />
            <Skeleton className="h-16 w-3/4 rounded-2xl" />
            <Skeleton className="h-10 w-1/2 self-end rounded-2xl bg-primary/20" />
        </div>
        <div className={"mt-auto flex items-center gap-3 pt-3 pb-3 pl-4 pr-4 " + _PANEL}>
            <Skeleton className="h-4 flex-1" />
            <Skeleton className="size-8 rounded-lg bg-primary/25" />
        </div>
    </div>;
}


cl def:pub ShopSkeleton() -> JsxElement {
    return <div className="flex w-full flex-col gap-5">
        <div className={"flex items-center gap-4 pt-3 pb-3 pl-4 pr-4 " + _PANEL}>
            <Skeleton className="h-5 w-20" />
            <Skeleton className="ml-auto h-8 w-40 rounded-lg" />
        </div>
        <div className="grid grid-cols-2 gap-4 lg:grid-cols-3">
            <div className={"flex flex-col gap-3 pt-3 pb-3 pl-3 pr-3 " + _PANEL}>
                <Skeleton className="h-24 w-full" />
                <Skeleton className="h-3.5 w-3/4" />
                <Skeleton className="h-3.5 w-1/3" />
            </div>
            <div className={"flex flex-col gap-3 pt-3 pb-3 pl-3 pr-3 " + _PANEL}>
                <Skeleton className="h-24 w-full" />
                <Skeleton className="h-3.5 w-3/4" />
                <Skeleton className="h-3.5 w-1/3" />
            </div>
            <div className={"flex flex-col gap-3 pt-3 pb-3 pl-3 pr-3 " + _PANEL}>
                <Skeleton className="h-24 w-full" />
                <Skeleton className="h-3.5 w-3/4" />
                <Skeleton className="h-3.5 w-1/3" />
            </div>
            <div className={"flex flex-col gap-3 pt-3 pb-3 pl-3 pr-3 " + _PANEL}>
                <Skeleton className="h-24 w-full" />
                <Skeleton className="h-3.5 w-3/4" />
                <Skeleton className="h-3.5 w-1/3" />
            </div>
            <div className={"flex flex-col gap-3 pt-3 pb-3 pl-3 pr-3 " + _PANEL}>
                <Skeleton className="h-24 w-full" />
                <Skeleton className="h-3.5 w-3/4" />
                <Skeleton className="h-3.5 w-1/3" />
            </div>
            <div className={"flex flex-col gap-3 pt-3 pb-3 pl-3 pr-3 " + _PANEL}>
                <Skeleton className="h-24 w-full" />
                <Skeleton className="h-3.5 w-3/4" />
                <Skeleton className="h-3.5 w-1/3" />
            </div>
        </div>
    </div>;
}


cl def:pub BlogSkeleton() -> JsxElement {
    return <div className="flex w-full gap-5">
        <div className="flex flex-1 flex-col gap-4">
            <div className={"flex gap-4 pt-4 pb-4 pl-4 pr-4 " + _PANEL}>
                <Skeleton className="size-16 shrink-0" />
                <div className="flex flex-1 flex-col gap-2.5">
                    <Skeleton className="h-4 w-2/3" />
                    <Skeleton className="h-3 w-full" />
                    <Skeleton className="h-3 w-1/2" />
                </div>
            </div>
            <div className={"flex gap-4 pt-4 pb-4 pl-4 pr-4 " + _PANEL}>
                <Skeleton className="size-16 shrink-0" />
                <div className="flex flex-1 flex-col gap-2.5">
                    <Skeleton className="h-4 w-2/3" />
                    <Skeleton className="h-3 w-full" />
                    <Skeleton className="h-3 w-1/2" />
                </div>
            </div>
            <div className={"flex gap-4 pt-4 pb-4 pl-4 pr-4 " + _PANEL}>
                <Skeleton className="size-16 shrink-0" />
                <div className="flex flex-1 flex-col gap-2.5">
                    <Skeleton className="h-4 w-2/3" />
                    <Skeleton className="h-3 w-full" />
                    <Skeleton className="h-3 w-1/2" />
                </div>
            </div>
            <div className={"flex gap-4 pt-4 pb-4 pl-4 pr-4 " + _PANEL}>
                <Skeleton className="size-16 shrink-0" />
                <div className="flex flex-1 flex-col gap-2.5">
                    <Skeleton className="h-4 w-2/3" />
                    <Skeleton className="h-3 w-full" />
                    <Skeleton className="h-3 w-1/2" />
                </div>
            </div>
        </div>
        <div className={"hidden lg:flex w-52 shrink-0 flex-col gap-3 pt-5 pb-5 pl-4 pr-4 " + _PANEL}>
            <Skeleton className="h-4 w-24" />
            <Skeleton className="h-3 w-full" />
            <Skeleton className="h-3 w-full" />
            <Skeleton className="h-3 w-full" />
            <Skeleton className="h-3 w-2/3" />
        </div>
    </div>;
}


cl def:pub AppSkeleton() -> JsxElement {
    return <div className="flex w-full flex-col gap-5">
        <div className={"flex items-center gap-4 pt-3 pb-3 pl-4 pr-4 " + _PANEL}>
            <Skeleton className="size-7 rounded-lg bg-primary/25" />
            <Skeleton className="h-4 w-28" />
            <Skeleton className="ml-auto size-8 rounded-full" />
        </div>
        <div className={"flex flex-col gap-4 pt-6 pb-6 pl-6 pr-6 " + _PANEL}>
            <Skeleton className="h-6 w-1/3" />
            <Skeleton className="h-3.5 w-full" />
            <Skeleton className="h-3.5 w-full" />
            <Skeleton className="h-3.5 w-2/3" />
            <div className="mt-2 flex gap-3">
                <Skeleton className="h-9 w-28 rounded-lg bg-primary/25" />
                <Skeleton className="h-9 w-24 rounded-lg" />
            </div>
        </div>
    </div>;
}


cl def:pub app() -> JsxElement {
    _applyPreviewTheme();
    sentinel = "__JAC_BUILDER" + "_BUILD_PROMPT__";
    hasPrompt = BUILD_PROMPT != sentinel;

    layout = "app";
    low = BUILD_PROMPT.lower();
    for pair in _HINTS {
        if layout == "app" and pair[0] in low {
            layout = pair[1];
        }
    }

    skeleton = <AppSkeleton />;
    if layout == "dashboard" {
        skeleton = <DashboardSkeleton />;
    } elif layout == "landing" {
        skeleton = <LandingSkeleton />;
    } elif layout == "chat" {
        skeleton = <ChatSkeleton />;
    } elif layout == "shop" {
        skeleton = <ShopSkeleton />;
    } elif layout == "blog" {
        skeleton = <BlogSkeleton />;
    }

    if not hasPrompt {
        return <div className="flex min-h-screen w-full items-center justify-center bg-background pt-8 pb-8 pl-8 pr-8 text-foreground">
            <div className="flex max-w-2xl flex-col items-center gap-6 text-center">
                <div className="select-none text-7xl" role="img" aria-label="sparkles">
                    {"✨"}
                </div>
                <p className="text-2xl font-medium leading-snug text-foreground sm:text-3xl">
                    {"When you start to build, changes will appear here."}
                </p>
            </div>
        </div>;
    }

    return <div className="flex min-h-screen w-full flex-col gap-6 bg-background pt-8 pb-8 pl-6 pr-6 text-foreground sm:pl-8 sm:pr-8">
        <div className="flex w-full flex-col gap-4">
            <div className="flex items-center gap-2.5">
                <span className="inline-block size-2 animate-pulse rounded-full bg-primary" />
                <span className="text-[11px] font-medium uppercase tracking-[0.22em] text-muted-foreground">
                    {"jac builder"}
                </span>
            </div>
            <h1 className="text-2xl font-semibold leading-tight tracking-tight sm:text-3xl">
                {"Cooking your app"}
                <span className="animate-pulse text-primary">{"…"}</span>
            </h1>
            <blockquote className="line-clamp-3 max-h-24 w-full max-w-3xl overflow-hidden border-l-2 border-primary/40 pt-1 pb-1 pl-4 text-base italic text-muted-foreground">
                {BUILD_PROMPT}
            </blockquote>
        </div>

        <div className="flex w-full flex-1 items-start opacity-80" aria-hidden="true">
            {skeleton}
        </div>

        <p className="w-full text-xs leading-relaxed tracking-wide text-muted-foreground/70">
            {"Hang tight — JacCoder is wiring this up. The preview refreshes the moment files land."}
        </p>
    </div>;
}
