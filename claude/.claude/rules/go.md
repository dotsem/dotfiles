---
paths:
  - "**/*.go"
  - "**/go.mod"
---

# Go

- Code must pass `gofmt` and the repo's `golangci-lint` config (errcheck, govet, staticcheck at minimum). Run them after changes when available.
- Define interfaces at the consumer, only when a consumer needs one. No speculative interfaces.
- Return early on errors; keep the happy path unindented. Wrap errors with context: `fmt.Errorf("load config: %w", err)`.
- Layout:
  - `/cmd/<app>/main.go`: entry points only.
  - `/internal`: all application and business logic (default home for new code).
  - `/pkg`: only for code deliberately meant to be imported by other modules.
- Tests: `xxx_test.go` next to the target, grouped with `t.Run`, assertions via `stretchr/testify/assert` (`require` when a failure must stop the test).
