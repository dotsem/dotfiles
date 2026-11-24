---
name: spec
description: "Write or close out a spec-first design doc in docs/specs/ for a non-trivial change: reads the code first, resolves open decisions in short question rounds with recommended answers, then writes a lean numbered spec for approval. Use when the user says 'spec' or asks to spec/plan out a change in a file."
---

### Workflow: spec
Purpose: a short, decision-focused spec the developer approves before any code is written. The spec is a snapshot, not a living doc.

#### 0. Is a spec worth it?
Write one only if any holds: touches schema or user data, spans several features or PRs, or has a real alternative worth recording. Otherwise say so in one line and offer a plan in chat instead.

#### 1. Look before asking
- Read the code the change touches, `CLAUDE.md`/`GUIDELINES.md`, `ROADMAP.md`, and existing `docs/specs/`.
- Specs with `Status: done` are background, not instructions; the code wins. Note any spec this one supersedes.
- Facts come from the code. Never ask the user what the repo already answers.
- If the conversation already settled the decisions, skip to step 3.

#### 2. Resolve open decisions in rounds
- At most 3 questions per round. Each question carries a recommended answer marked `→` and is worded so "yes" accepts it.
- Ask only about decisions (scope, trade-offs, behaviour), never about facts.
- Stop when no open decisions are left. Don't pad with questions you can answer sensibly yourself; state those as assumptions in the spec.

#### 3. Write the file
- Path: `docs/specs/NNNN-slug.md`, where NNNN is the next free number. Use a folder with `spec.md` + `plan.md` only when the work spans several PRs.
- Template (keep a blank line around every heading, list and code block, so markdownlint passes):
  ```markdown
  # NNNN: <title>
  Status: draft
  Supersedes: <NNNN, or omit>

  ## Why
  ## Scope / Non-goals
  ## Design            <!-- decisions; rejected alternatives one line each -->
  ## Risks
  ## Plan              <!-- PR breakdown, files touched; moves to plan.md if it outgrows this -->
  ## Verification      <!-- how each risk gets caught: test, check, manual step -->
  ## Assumptions       <!-- things decided without asking; omit if empty -->
  ```
- Design records a decision in detail only if it is hard to reverse, surprising without context, and a real trade-off. Everything else is one line or nothing.
- No implementation in prose. Code only when a snippet pins down a decision better than words (a schema, a signature). File paths belong in Plan only.
- Size it to the change: a small change fits on one screen. Hard limit 300 lines. If the spec reads longer than the code it describes, it has written the code: cut it.

#### 4. Self-check before handing over
- Every user requirement maps to a Design or Plan item, and every risk has a Verification line.
- No placeholders, TBDs, or contradictions with `CLAUDE.md` rules.
- Names and types match the actual code.

#### 5. Hand over
- Reply with the file link, a 3-line summary, and any remaining open questions. Then stop and wait.
- On approval, set `Status: approved`. Never start implementing, run git, or spawn subagents from this skill.

#### Closing out (when the user says the work is done)
- Prefer `/spec-audit`: it checks the code against the spec and closes it out only if everything matches. Close out by hand only when the user says to skip the audit.
- Set `Status: done (vX.Y.Z)`. Delete the Plan section or `plan.md`; keep Why, Design, Risks.
- Never edit a done spec to match later changes. Write a new spec and add `Superseded by NNNN` to the old one.
- Don't move done specs to an archive folder; links must keep working.
