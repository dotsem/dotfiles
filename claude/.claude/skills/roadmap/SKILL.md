---
name: roadmap
description: "Check an existing roadmap against the codebase, or brainstorm next features and refactors as a separate proposal. Use when the user says 'roadmap' or asks what's done, stale or next."
---

### Workflow: roadmap

Pick the mode from the request; ask only if it's genuinely ambiguous.

**Mode A: check** ("is this up to date?")
1. Find the roadmap (`ROADMAP.md`, `docs/`, or what the user points to) and verify each item against the code, git log and `docs/specs/`.
2. Report per item: done (with evidence: file or commit), in progress, stale/obsolete, or blocked (and by what).
3. Flag sequencing problems: items that depend on unfinished ones, or are ordered against their dependencies.
4. Update the roadmap file only for status changes the evidence proves. Ask before rewording, reordering or removing items.

**Mode B: brainstorm** ("what's next?")
1. Base ideas on the actual code: real gaps, `shortcut:`/`TODO` comments, tech debt, missing tests, pain points in the architecture.
2. Present a separate proposal grouped as features, refactors and debt, each with one line on why and a rough size (S/M/L).
3. Be honest about weak ideas, including the user's. Never insert proposals into the roadmap file until the user picks them.
