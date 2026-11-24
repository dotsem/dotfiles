---
paths:
  - "**/Dockerfile*"
  - "**/*.dockerfile"
  - "**/compose*.y*ml"
  - "**/docker-compose*.y*ml"
---

# Docker

- Multi-stage builds: build tools stay in the build stage, and the runtime stage gets only the artifact.
- Never run as root. Create or use a non-privileged user and switch with `USER` (e.g. `USER node`, or `adduser -D app` then `USER app` on Alpine).
- Pin base images to a minor version (`node:22.11-alpine`, `golang:1.23-alpine`). Never use `latest`.
- Layer order: copy the dependency manifests (`package.json` + lockfile, `go.mod`/`go.sum`, `pubspec.yaml`/`pubspec.lock`), install, then copy the source.
