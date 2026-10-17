# Empty

A blank canvas — the minimal jac-shadcn starter the other templates are built on.

One client page, the violet theme wired up, and nothing else in the way. Start
here when none of the other templates fit, and describe what you want to build.

## What you get

- `main.jac` — a `cl { }` block with a single `def:pub app()` page (a centered
  card). This is the whole app.
- `components/ui/` — the two jac-shadcn primitives (`Button`, `Card`) the page
  uses. Add more with `jac add --shadcn <name>`.
- `styles/global.css` — semantic design tokens and the theme, already wired up.
- `lib/utils.jac` — `cn()` for merging class names.

## Run it

```bash
jac install
jac start --dev
```

Open <http://localhost:8000>.

## Where to go next

- **Add a page / routing** — create a `pages/` directory; files become routes
  by convention. See `jac guide jac-cl-routing`.
- **Add a backend** — create `services/foo.sv.jac` with `def:pub` functions;
  each becomes a `POST /function/<name>` REST endpoint automatically, and data
  hung off `root` persists with no database to set up (Jac stores the graph for
  you — SQLite in `.jac/data/` by default, MongoDB via `MONGODB_URI`). See
  `jac guide jac-sv-endpoints` and `jac guide jac-sv-persistence`.
- **Add auth** — see `jac guide jac-sv-auth` and `jac guide jac-cl-auth`.

`AGENTS.md` lists the reference guides bundled with the compiler; read them
before writing Jac — the syntax is easy to confuse with Python or JSX.
