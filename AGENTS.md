# CaseZero contributor and coding-agent guide

This is a Jac 0.34.23 web application. Jac syntax is release-sensitive and easy to confuse with Python, JavaScript, or JSX. Before changing `.jac` files, consult the guides shipped with the installed Jac CLI and check the result with the project commands below.

## Project status and architecture

The game is now playable end to end. `main.jac` registers the server endpoints from `services/gameApi.jac` and `services/advisors.jac` and routes `/case/:session_id` (also `/evidence/:session_id`) to `components/InvestigationRoom.jac`, the investigation dashboard. Fixed case facts live in `lib/` (`missing_prototype_case.jac`, `case_knowledge.jac`); deterministic rules live in `services/caseLogic.jac` and `services/caseManager.jac`; the four advisor agents live in `services/advisors.jac` and call a model only through `services/llmBridge.jac`. Without `GEMINI_API_KEY` every agent runs on rules. The case engine, never a model, decides the verdict.

Folder and file responsibilities:

- `main.jac`: web-app entry point and current single-page component wiring.
- `components/`: application-level client components. `InvestigationRoom.jac` owns game state; the `*Panel.jac` files render one tab each.
- `components/ui/`: generated/managed shadcn primitives. Import these; do not edit them by hand.
- `services/`: server-side/domain service code when it is deliberately wired into the application. `caseService.jac` currently contains deterministic investigation starter logic but is not connected to `main.jac`.
- `components/CaseZeroInvestigation.jac`: investigation starter UI, currently inactive and not connected to the entry route.
- `styles/global.css`: Tailwind and shadcn global styling.
- `lib/utils.jac`: shared UI class-name helper.
- `jac.toml`: Jac project, dependency, client Vite, theme, and app metadata configuration.
- `frontend.cl.jac`: template/JacBuilder splash implementation; it is not the CaseZero app entry point.
- `dist/` and `.jac/`: generated output. Do not treat them as source or make manual fixes there.

Do not implement roadmap stages or wire inactive investigation files into the live route without explicit approval.

## Development commands

Run commands from the project root:

```bash
jac --version
jac install
jac check main.jac
jac start --dev main.jac
```

The project currently targets Jac 0.34.23. Use `jac check main.jac` as the source-level check. `jac start --dev main.jac` is the local development command; open the URL reported by the command. In JacHammer, the platform owns and manages the preview process: use the IDE Preview and its URL rather than starting or killing another server.

For Jac's release-specific syntax, use the installed CLI references:

```bash
jac guide
jac guide jac-core-cheatsheet
jac guide jac-types
jac guide <guide-name>
```

The existing template also documents `jac run <file>` for executable Jac scripts and `jac browse <action>` for its CLI browser workflow. These are not substitutes for checking the running web app in JacHammer Preview.

## Jac conventions

- Use Jac 0.34.23 syntax and explicit types for function parameters, return values, and state fields.
- Jac blocks use braces and statements end in semicolons; control flow is Python-like. Do not write application JSX in `.js`, `.jsx`, or `.tsx` files.
- JSX-bearing Jac declarations are inferred as client-side. Keep the current manual single-page entry signature `app()` unless the routing model is deliberately changed.
- Use dotted, unquoted module paths for local Jac imports and quoted string paths for CSS/npm imports, following the current `main.jac` and component examples.
- Use `has` fields for reactive client state and typed event parameters such as `MouseEvent` or `ChangeEvent` when applicable. Reassign collections rather than mutating them in place if a UI update is expected.
- Compose installed UI primitives rather than duplicating them. Use Tailwind utilities and existing theme tokens; do not hand-edit generated shadcn primitives.
- If client code later calls a server module, follow the release guide's client/server import pattern, register endpoints through the entry module as required, and `await` RPC calls.
- Keep application behavior aligned with the approved stage. Roadmap items are not implemented requirements until approved.

## Security requirements

- Never hardcode or commit passwords, API keys, tokens, or private data. `.env` and `.env.*` are ignored by Git; do not remove these rules. Only non-secret templates belong in `.env.example`.
- For JacHammer previews, ask the project owner to configure provider secrets in IDE Environment settings. Never assume a key exists or put a key in source, README, logs, or screenshots.
- Future server endpoints must validate input and enforce authorization on the server. Client controls are not authorization.
- Use fictional case data only. Do not expose secrets or sensitive personal information in prompts, error output, fixtures, or logs.
- Keep normal JSX escaping for dynamic text; do not use unsafe raw HTML for user-controlled values.

## Verification and quality expectations

1. Run `jac check main.jac` after Jac source changes and resolve errors before handing back.
2. Use the managed JacHammer Preview to verify the affected route actually renders; inspect both desktop and phone layouts when available.
3. Exercise each changed interaction once. Check the browser report for JavaScript errors and verify that the visible result matches the stage scope.
4. For future backend work, verify validation, error paths, permissions, and the client/server contract; add focused tests for deterministic domain behavior. Do not claim test coverage that was not run.
5. Keep generated output such as `dist/` separate from source changes. Diagnose and fix the source rather than editing compiler output.

## Incremental workflow and commits

- Work only on the user-approved stage. Read the current files and applicable Jac guide before editing; preserve useful existing guidance.
- Prefer small, reviewable changes. Keep a stage's documentation, UI, domain behavior, and infrastructure changes distinct where practical.
- Before a commit, review `git diff` and the changed-file list when Git metadata is available, run the relevant checks, and make sure the preview remains usable.
- Use one descriptive commit per coherent approved change. Suggested Stage 2 message: `docs: define CaseZero architecture and development workflow`.
- Some JacHammer workspace copies do not include `.git`; if Git commands report that the directory is not a repository, state that limitation. Do not claim to have reviewed a Git diff, created a commit, or changed repository history in that situation.
- Wait for approval before beginning the next roadmap stage.

## 30-stage roadmap

Planning only; do not implement an item without approval.

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

## Existing Jac reference guidance

The Jac CLI includes curated reference guides. Start with `jac guide jac-core-cheatsheet` and `jac guide jac-types`; use `jac guide --search <keyword>` to locate topic guidance. Consult `jac guide jac-fullstack-patterns` before introducing server endpoints and `jac guide jac-cl-components` before changing client components. The compiler's guidance for the installed release is authoritative over examples remembered from other Jac versions.
