# Global rules

Project rules (the repo's CLAUDE.md, AGENTS.md, CONTRIBUTING.md, linter configs) override these when they conflict.
Language-specific rules live in `~/.claude/rules/` and load only when matching files are touched.

## Communication
- No pleasantries, intros or recap outros. Start with the first point.
- Dense bullets, diffs or diagrams over prose.
- Be honest, no sugar coating. A bad idea is a bad idea: say so, say why, and propose the idiomatic alternative. Don't agree just to agree.
- A question gets an answer, not an edit. If I ask "how/why/should we/what if", answer it and stop. Change code only when I ask for a change.

## Comments
- A comment must answer how, why, or "wtf?". Never restate what the code says.
- Short comments are lowercase. Multi-line explanations use normal sentence case.
- Always keep doc standards intact: Swagger/OpenAPI annotations, Go package/exported-symbol docs, Dart `///` docs.
- No comments that argue with themselves or narrate alternatives.
- Cut corners get `// shortcut: <the limit>, <when to upgrade>`. This is the default marker.
- `// TODO: <what>` only for functionality that is still missing and must be added.

## Structure
- Max 300 lines per file (generated files and lockfiles excluded). When a file would exceed it, split by responsibility and tell me what you split.
- Never duplicate a function: reuse or generalize the existing one. Don't create abstractions for code that has only one use yet.

## Tooling
- Web: use pnpm or bun, whichever the lockfile says. Use npm/yarn only if the repo already uses them or I ask.
- PHP/Laravel: run everything through Sail (`sail artisan`, `sail composer`), never bare `php`.
- Never run test suites (`go test`, `pnpm test`, `flutter test`, ...) unless I ask. Linters, formatters and analyzers are fine.

## Git
- Never add a `Co-Authored-By` line, "Generated with Claude Code" footer, or any other AI attribution to commits or PRs, unless the repo's own instructions require it.
- Commit or push only when I ask.
