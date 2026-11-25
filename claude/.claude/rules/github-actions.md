---
paths:
  - "**/.github/workflows/**"
  - "**/action.yml"
  - "**/action.yaml"
  - "**/.github/dependabot.yml"
---

# GitHub Actions

## Reuse first
- Before writing jobs, check whether a `dotactions/<stack>` reusable workflow or composite action covers it (go, node, flutter, docker, security, sarif-reporter, coverage-action). Call it instead of rebuilding it; its README lists the permissions the calling job must grant.
- Reusable workflows can only narrow the caller's token permissions, never widen them.

## Pinning
- Third-party actions: full 40-char commit SHA of a release tag with the version as a comment: `uses: actions/checkout@<sha> # v4.2.2`.
- `dotactions/*`: SHA pin, or a floating minor tag (`@v0.1`) as its README allows.
- Resolve SHAs with `git ls-remote https://github.com/<owner>/<repo> 'refs/tags/<tag>^{}'`. Never guess or invent a SHA; if it can't be resolved, say so.
- Never `@main`, `@master`, `@latest` or a major-only tag.
- Keep `.github/dependabot.yml` with the `github-actions` ecosystem so pins get updated.

## Security
- Top-level `permissions: contents: read`; widen per job, only for what that job does.
- Never interpolate untrusted input (`github.event.*`, `github.head_ref`, PR titles/bodies, issue text) directly in `run:`. Pass it through `env:` and quote it: `"$PR_TITLE"`.
- Avoid `pull_request_target` and `workflow_run`. If unavoidable, never check out or execute the PR's code in that job.
- `actions/checkout` gets `persist-credentials: false` unless the job pushes.
- Cloud deploys use OIDC (`id-token: write`), not long-lived keys. Secrets never reach fork PRs.
- Deploy jobs run in a GitHub environment with required reviewers.

## Structure
- Separate jobs for validate, build, release and deploy; later stages `needs:` earlier ones.
- Every workflow sets `concurrency` (`group: ${{ github.workflow }}-${{ github.ref }}`, `cancel-in-progress` on PRs). Every job sets `timeout-minutes`.
- Use the `setup-*` actions' built-in cache before adding `actions/cache`.
- Path filters on `push`/`pull_request` when only part of the repo is relevant.

## Validate
- Run `actionlint` and `zizmor` on changed workflows after editing, and fix their findings. Both are linters, so the test guard doesn't apply.
