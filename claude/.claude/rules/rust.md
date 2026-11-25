---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---

# Rust

- Code must pass `cargo fmt` and `cargo clippy` without warnings. Run them after changes.
- Return `Result` and propagate with `?`. No `unwrap()` or `expect()` outside tests, unless the invariant is proven and a `// why:` comment says so. Add context to errors (`thiserror` for libraries, `anyhow` for binaries, whichever the project uses).
- Define traits at the consumer, only when a second implementation or a test double needs one.
- Prefer borrowing over cloning. A `.clone()` to satisfy the borrow checker needs a reason.
- Keep `unsafe` out unless unavoidable. Every `unsafe` block gets a `// safety:` comment naming the invariant.
- Layout: logic lives in library crates or modules, `main.rs` only wires things together. Split large crates into a workspace under `crates/`.
- Tests: unit tests in a `#[cfg(test)] mod tests` next to the code, integration tests in `tests/`. Run a single test with `cargo test <name>`, not the whole workspace.
