---
name: spec-audit
description: "Check an implementation against its spec in docs/specs/: finds missing requirements, deviations, scope creep and unverified risks, then closes the spec out as done if everything matches. Use when the user says 'spec-audit' or asks whether the code matches, implements or follows a spec."
---

### Workflow: spec-audit

#### 1. Inputs
- Spec: the number or path the user gives; otherwise the `approved` spec in `docs/specs/` that matches the current branch. Ask if more than one fits.
- Changes, unless the user gives a range: all three of
  - committed on the branch: `git diff $(git merge-base HEAD <default>)` (also covers staged and unstaged edits to tracked files)
  - untracked new files: `git ls-files --others --exclude-standard`; read them in full, since `git diff` never shows them
  - on the default branch itself, the merge-base is HEAD, so the uncommitted changes are the whole implementation
- Never conclude "nothing is implemented" before checking all three.
- Status: a `done` spec is closed, so say so and stop. A `draft` spec is audited anyway, with a note that it was never approved; close it out only if the user confirms.

#### 2. Audit (read-only)
- Go through every item in the spec's sections, whatever the headings are (scope, design decisions, plan, verification), and mark each one:
  - **met**, with `file:line` evidence
  - **missing**: not implemented
  - **deviated**: implemented differently than decided; say how
- Non-goals: flag any code that implements one.
- Extra: flag changes that no spec item covers (scope creep), ignoring trivial fixups.
- Verification: each item needs a matching test, check or documented manual step in the diff. Never run tests to prove it.
- Don't review code quality or bugs; that's `/code-review` and `/ponytail-review`.
- Base every finding on the code you read. If an item can't be judged from the diff, mark it **unclear** with why.

#### 3. Outcome
- **Everything met, nothing extra, no non-goal hits, nothing unclear:** close the spec out following the `spec` skill's closing-out rules. Set `Status: done (vX.Y.Z)`, using the version from the latest git tag or the project manifest (plain `Status: done` if there is none), and remove the Plan section or `plan.md`. This is the only edit this skill makes. Reply with one line and the file link.
- **Anything else:** change nothing. Report a table (item | status | evidence or gap), followed by the decisions the user has to make: fix the code, or record a deviation in the spec while it is still `approved`. Then stop and wait.
