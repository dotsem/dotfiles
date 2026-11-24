---
name: readme
description: "Write or rewrite a clean, high-density README.md for the repository, derived from the actual project files. Use when the user says 'readme'."
---

### Workflow: readme

1. Read before writing: manifests (`go.mod`, `package.json` + lockfile, `pubspec.yaml`, `composer.json`), Dockerfiles/compose, `.env.example`, Makefile/Taskfile, CI config, `LICENSE`. Every command and version in the README must come from these files.
2. Tone: strict technical documentation. No emoji, no decorative badges, no marketing copy. Use headings, tables and code blocks for hierarchy.
3. Structure (omit sections that don't apply):
   - Name and one-paragraph description: what it does and the high-level architecture.
   - Tech stack and prerequisites: runtimes and versions as pinned in the repo (Go, Dart/Flutter SDK, Bun/pnpm, Laravel Sail, Docker).
   - Getting started: install, environment variables (from `.env.example`), run locally.
   - Development: lint, format, test and build commands that actually exist in the repo.
   - Contributing: only conventions the repo actually enforces (branching, linters, commit style).
   - License: name it from `LICENSE`. If there is none, say so and ask; never invent one.
4. If a README exists, keep correct content and sections the user wrote by hand; fix what's stale.
