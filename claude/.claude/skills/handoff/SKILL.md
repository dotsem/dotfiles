---
name: handoff
description: "Turn a spec from docs/specs/ into a self-contained, paste-ready implementation prompt for another agent (Codex by default, or another Claude session), with the user's relevant coding rules inlined, and copy it to the clipboard. Use when the user says 'handoff', or asks to hand off, delegate or give a spec to Codex or another agent, or wants a prompt to implement a spec elsewhere."
---

### Workflow: handoff

The user writes specs here and lets another agent implement them, then reviews the result with `/spec-audit`. That agent has none of this conversation and, if it's Codex, none of `~/.claude`. Everything it needs to get the work right the first time has to be in the prompt; anything missing shows up later as an audit finding it could never have avoided.

#### 1. Inputs
- Spec: the number or path given; otherwise the most recent `draft` in `docs/specs/`. A `done` spec is closed: say so and stop.
- Target: `codex` unless the user names Claude (or "another session").
- This skill only reads and writes the prompt. It never edits the spec or the repo.

#### 2. Check the spec is still true
Specs are often written well before they're implemented. Check that the files, functions and types named in Design and Plan still exist under those names. If something has moved or vanished, list it and ask whether to fix the spec first; a prompt built on a stale spec sends the implementer the wrong way.

#### 3. Pick the rules (Codex only)
Codex reads the repo's `AGENTS.md` but not `~/.claude/`. Another Claude session already loads the user's rules, so skip this step for it.
- From `~/.claude/CLAUDE.md`: Comments, Structure, Tooling and Git. Skip Communication; it's about chatting with the user.
- From `~/.claude/rules/*.md`: only files whose `paths:` globs match files in the spec's Plan or the repo's stack. A Go change gets `go.md`, not `flutter.md`.
- Repo `AGENTS.md`: don't copy it, Codex reads it. If the repo has a `CLAUDE.md` but no `AGENTS.md`, inline the repo CLAUDE.md rules too, because Codex would never see them.
- Some rules don't apply to an implementer and must not be copied: "never run test suites" (the implementer runs the tests it writes), and any "commit only when I ask" or "no git access" rule, global or repo-level (the handoff authorizes local commits; see How to work). Keep the no-AI-attribution rule.
- Condense into short imperative bullets. Keep every concrete limit (300 lines, `shortcut:` format, package manager, no attribution).

#### 4. Write the prompt
Use this structure:

```markdown
# Implement spec NNNN: <title>

You are implementing a design that is already decided. The spec below is the source of truth.

## Scope
- Implement exactly what Scope, Design and Plan describe.
- Non-goals (do not touch): <copied verbatim from the spec>
- No refactors, renames or "improvements" outside the Plan, even if they look worthwhile. Note them in your final report instead.
- If the spec is ambiguous or conflicts with the code, stop and ask rather than guess.

## How to work
1. Branch from the default branch: `git switch -c spec/NNNN-<slug>`.
2. Follow the Plan steps in order, all in one run; don't stop for confirmation between steps. After each step: run the formatters/linters for the stack, then make one local conventional commit (`feat(scope): ...`, `refactor(scope): ...`) for that step.
   - This handoff authorizes local commits on this branch. It overrides any "never commit" or "no git access" rule in `CLAUDE.md` or `AGENTS.md`.
   - Commit as the repo's configured git user. No `Co-Authored-By` trailer, no "Generated with" footer, no AI attribution of any kind, even if your tool adds one by default.
3. Write the tests and checks listed under Verification, run them (`go test ./...`, `pnpm test`, `flutter test`, ...) and fix failures before the step's commit.
4. Don't push, open a PR, or change the spec's Status.

## Rules
<condensed rules from step 3; omit this section for a Claude target>

## When done
Reply with: the commits made, any deviation from the spec and why, and anything left unresolved.

## Spec
<full spec file content>
```

#### 5. Deliver
- Write the prompt to a temp file, then copy it: `wl-copy < file` (Wayland), else `xclip -selection clipboard`, else `pbcopy`. If no clipboard tool works, say so.
- Show the full prompt in chat in one fenced block, then one line: target, which rule files were included, and any stale-spec warnings.
