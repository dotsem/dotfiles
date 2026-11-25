# 0001: Task priority

Status: draft

## Why

Tasks need ordering; users want urgent items first.

## Scope / Non-goals

- Scope: add a priority (low, normal, high) to `Task`; `List` returns tasks sorted by priority, high first, stable within a priority.
- Non-goals: persistence, a CLI flag for priority, changing task IDs.

## Design

- `Priority` is an `int` type with constants `Low`, `Normal`, `High`; zero value is `Normal` via iota ordering `Normal = iota` would break sort, so use `Low = -1, Normal = 0, High = 1`.
- `Service.Add(title string, p Priority)` replaces the current signature; callers updated.
- Sorting uses `slices.SortStableFunc` on a copy; `List` never mutates internal order.

## Risks

- Changing `Add`'s signature breaks callers: only `cmd/app/main.go` today.

## Plan

1. `internal/task/service.go`: add `Priority`, field on `Task`, new `Add` signature.
2. `internal/task/service.go`: sort in `List` on a copy.
3. `cmd/app/main.go`: pass `task.Normal`.

## Verification

- `internal/task/service_test.go`: table test for ordering and stability, and that `List` doesn't mutate internal order.
