# CaseZero

CaseZero is a detective-noir mystery experience. Stage 1 provides a responsive landing page introducing the fictional case, **The Missing Prototype**, and a Start Investigation call to action. The investigation experience and game mechanics are intentionally not implemented in this stage.

## Requirements

- Jac 0.34.23
- JacHammer project preview, or a local Jac installation for development

## Run locally

From the project root, install the configured project dependencies and start the Jac web app:

```bash
jac install
jac start --dev main.jac
```

Open the app URL reported by the Jac server. In JacHammer, the platform manages the preview server; use the project's Preview rather than starting a second server manually. The preview URL is provided by JacHammer and is not a fixed localhost address.

## Check

```bash
jac check main.jac
```

`dist/` is generated output and is not the source of the application.
