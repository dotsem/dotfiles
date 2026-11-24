---
name: doc
description: "Write deep technical documentation for one component, subsystem, API or design pattern, grounded in the actual code. Use when the user says 'doc' or 'documentation', or asks to document how something works."
---

### Workflow: doc

1. Scope: document only the target the user named. No invented features, no roadmap, no generic intro to the language or framework.
2. Read first: trace the real code paths (entry points, state, side effects, error handling) before writing. Every claim must match the code; if something is unclear, write it as an open question instead of guessing.
3. Depth over summary: cover state and lifecycle, data flow, side effects, edge cases, failure modes and the trade-offs behind the design. Skip what a reader gets from the signatures alone.
4. Diagrams: add a Mermaid diagram (see the `flow` skill) only where a flow or lifecycle is hard to follow in prose.
5. Output: if the repo has a `docs/` folder, write to `docs/<topic>.md` and match its existing style; otherwise reply in chat and ask before creating files. Never duplicate Swagger/OpenAPI or code doc comments; link to them.
