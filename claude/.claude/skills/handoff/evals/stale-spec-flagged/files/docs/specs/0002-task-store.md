# 0002: Persist tasks

Status: draft

## Why

Tasks are lost on restart.

## Scope / Non-goals

- Scope: save tasks to a JSON file through `Store.Save` in `internal/task/store.go`, and load them in `NewServiceFromStore`.
- Non-goals: databases, concurrency.

## Design

- `Store.Save([]Task) error` already exists in `internal/task/store.go`; reuse it.
- `NewServiceFromStore(path string) (*Service, error)` loads via `Store.Load`.

## Plan

1. `internal/task/store.go`: add `Store.Load`.
2. `internal/task/service.go`: add `NewServiceFromStore`.

## Verification

- `internal/task/store_test.go`: round-trip save/load.
