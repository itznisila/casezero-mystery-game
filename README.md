# CaseZero

CaseZero is a detective-noir mystery experience built with Jac. The current application is **Stage 1**: a responsive landing page introducing the fictional case *The Missing Prototype*. Its Start Investigation button acknowledges the click; it does not begin a playable investigation. No AI agent, interview flow, or game backend is currently connected to the active route.

## Current architecture

- `main.jac` imports the global stylesheet and `CaseZeroLanding`, then exports the single-page `app()` entry point.
- `components/CaseZeroLanding.jac` owns the landing-page UI and its local button acknowledgment state.
- `components/ui/` contains Jac shadcn components. Treat these as managed UI primitives: import and compose them; do not hand-edit them.
- `styles/global.css` provides the Tailwind/shadcn theme imported by `main.jac`.
- `lib/utils.jac` contains the shadcn class-name helper.
- `services/caseService.jac` and `components/CaseZeroInvestigation.jac` are investigation-related starter files, but are not imported by `main.jac` and are not active application behavior. Verify and deliberately connect or replace them only in a later approved stage.
- `frontend.cl.jac` is JacBuilder template splash/scaffold code, not the active entry point.
- `jac.toml` declares the web-app entry, dependencies, Tailwind Vite setup, theme, and app metadata.
- `dist/` and `.jac/` are generated output; edit source files instead.

The project uses Jac 0.34.23. Jac infers client placement for JSX-bearing `.jac` components. In `main.jac`, the global CSS import is a string-path import and local Jac modules use dotted imports. The single-page entry is `def:pub app() -> JsxElement`.

## Development workflow

Use the project root as the working directory.

```bash
jac install
jac check main.jac
jac start --dev main.jac
```

`jac install` installs the dependencies declared in `jac.toml`. `jac check main.jac` checks the application entry and its imported Jac code. `jac start --dev main.jac` starts the local development server; open the application URL it reports.

In JacHammer, the platform owns the preview process. Use the IDE's managed Preview and its displayed URL; do not start a competing server. Client edits are picked up by the preview's development workflow. If investigating a local compiler/server failure, `cat .jac-server.log` may show diagnostics when that log exists.

Before writing or editing Jac, consult the release-matched guides bundled with the CLI. Useful commands include `jac guide`, `jac guide jac-core-cheatsheet`, `jac guide jac-types`, and `jac guide <guide-name>`. Jac uses Python-like control flow with braces and semicolon-terminated statements; JSX is written in `.jac` files, not authored as separate JavaScript/TypeScript source. Use Jac's typed event handlers and state fields in client components, and always `await` client-to-server RPC calls when such calls are introduced.

## Security and data handling

- Never commit credentials, API keys, access tokens, or real case data. `.env` and `.env.*` are ignored; keep only non-secret examples in `.env.example`.
- In JacHammer, configure future provider credentials through the IDE's Environment settings and ask the project owner to supply their own key. Do not assume a key is available. For local development, `.env.example` documents the optional variable names only; `.env` and `.env.*` are ignored and must never contain committed values.
- If a future approved stage adds AI, keep provider credentials on the Jac server and access them only through server-side configuration such as the existing `jac.toml` `${OPENAI_API_KEY:-}` interpolation. Never use `VITE_`-prefixed secret names, import secrets into client modules, return them from endpoints, or embed them in browser-visible configuration. Restart the managed preview after changing environment settings if required for the new values to load.
- No LLM integration is active in Stage 1; this documentation does not configure a provider or call one.
- Validate and bound user-provided values at the server boundary when future endpoints are introduced. Keep authorization checks server-side; do not treat client-side visibility as access control.
- Use fictional identities and evidence. Do not put personal or confidential information in logs, prompts, fixtures, or screenshots.
- Do not render untrusted strings as raw HTML. Preserve framework escaping and avoid logging secrets.

## Testing expectations

For each change, run `jac check main.jac` and use the managed Preview to check the affected page at desktop and phone widths. Exercise the changed user interaction once and inspect visible error states. For changes involving an endpoint, also verify the client/server contract and test the actual flow through Preview; add focused Jac tests when testable behavior is introduced. Do not claim functionality that has not been verified. Generated output under `dist/` is not a substitute for testing source.

## Incremental development and commits

Develop one approved stage at a time. Keep each change focused, check the diff before committing, and avoid mixing documentation, gameplay, and infrastructure changes without a reason. A commit should leave the app checkable and the preview usable; commit messages should describe the completed change, for example `docs: define CaseZero architecture and development workflow`. This workspace may be opened without Git metadata; if Git is unavailable, report that limitation instead of claiming a diff or commit was produced.

## 30-stage roadmap

This is a planning outline, not a claim that the features exist. Implement stages only after approval; refine details as requirements are agreed.

1. CaseZero landing page (complete).
2. Architecture and development documentation (current stage).
3. Investigation entry and case briefing.
4. Case-file domain model and deterministic case data.
5. Evidence board and clue inspection.
6. Evidence collection state and persistence design.
7. Suspect profiles and access rules.
8. Interview interface.
9. Deterministic interview response rules.
10. Evidence-aware interview context.
11. Contradiction and timeline comparison.
12. Investigator notes.
13. Lead detective guidance.
14. Accusation flow.
15. Evidence-backed case resolution.
16. Progress and case completion feedback.
17. Accessible navigation and keyboard review.
18. Responsive investigation workspace.
19. Loading, empty, and error-state review.
20. Server-side input validation and permission checks.
21. Automated tests for case rules.
22. Endpoint and client-contract tests.
23. Optional byLLM interview enhancement behind deterministic rules.
24. Configure provider secrets through environment settings.
25. AI output validation and safe fallback behavior.
26. Agent roles and bounded investigation tools.
27. Agent collaboration and evidence citations.
28. Replayable case sessions and persistence hardening.
29. End-to-end QA, security review, and performance pass.
30. Release documentation and approved deployment preparation.
