---
paths:
  - "**/*.svelte"
  - "**/svelte.config.*"
  - "src/routes/**"
  - "src/lib/**"
---

# SvelteKit

- Svelte 5 runes only (`$state`, `$derived`, `$effect`, `$props`). Never legacy `$:`, `export let` or stores for local state.
- Components stay atomic. Layout components receive data via props; loading and fetching live in `+page.ts` / `+page.server.ts`.
- Style only with Tailwind utility classes, using the project's theme tokens. No custom CSS or arbitrary values when a token exists.
- Layout:
  - `src/lib/components/`: reusable UI.
  - `src/lib/server/`: server-only code.
  - `src/routes/[route]/`: `+page.svelte` (view), `+page.server.ts` (load and form actions), `+server.ts` (REST endpoints).
- Tests: Vitest for logic, transformers and stores. Playwright for end-to-end flows.
