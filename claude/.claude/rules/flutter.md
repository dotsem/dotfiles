---
paths:
  - "**/*.dart"
  - "**/pubspec.yaml"
---

# Flutter / Dart

- `environment.sdk` in pubspec is the Dart SDK version, not Flutter's.
- Target the latest or second-latest stable Flutter. No legacy syntax or backports.
- Run `dart format .` and `flutter analyze` after changes and fix all warnings. Never add `// ignore:` without a `// why:` next to it.
- Architecture: MVVM inside a feature-first layout. Views are dumb widgets; ViewModels hold state and call use-cases or repositories. Use the state management library the project already uses (Riverpod, Bloc or signals).
- Extract large nested widget trees into separate `StatelessWidget` classes, not `_buildX()` helper methods.
- Always take colors, text styles and spacing from `Theme.of(context)`. No hardcoded styling.
- Layout:
  ```
  lib/
  ├── features/<feature>/
  │   ├── data/          # data sources, repository implementations, DTOs
  │   ├── domain/        # entities, use-cases, repository interfaces
  │   └── presentation/  # views (widgets) and view models
  └── core/              # shared utils, theme, network clients
  ```
- Tests: `flutter_test` with `mocktail` (or `mockito` if the project already uses it), grouped with `group('<feature>', ...)`.

## Dart 3

- Model variants and UI state with `sealed` classes and exhaustive `switch` expressions. Use records for ad-hoc tuples.
- No `dynamic`. No `!` unless non-null is proven by the lines above it.
- `const` constructors and `const` widgets wherever possible. Long or unbounded lists use `.builder`.

## Riverpod 3

- Use `Notifier`, `AsyncNotifier` and `NotifierProvider`. `StateProvider`, `StateNotifierProvider` and `ChangeNotifierProvider` only exist in `flutter_riverpod/legacy.dart`: never use them.
- `ref.watch` in `build`, `ref.read` only in callbacks and event handlers, never in `build`.
- No `@riverpod` codegen unless the project already uses it.

## Async and lifecycle

- After any `await` in a widget or notifier that touches `BuildContext`, check `context.mounted` first.
- Dispose every controller, focus node, timer and stream subscription in `dispose()`.
- Fire-and-forget calls are wrapped in `unawaited(...)`, never left as a floating future.

## Routing, i18n, generated code

- Route paths and names are constants in one place. No string literals at call sites.
- If the project has `l10n.yaml`, all user-visible strings come from `AppLocalizations`.
- Never hand-edit `*.g.dart` or `*.freezed.dart`. Regenerate with `dart run build_runner build -d`.

## Tests

- Override providers through `ProviderScope(overrides: [...])`, not by mutating globals.
- Use `pump(duration)` for animations that never settle. `pumpAndSettle` hangs on them.
- The project's own `GUIDELINES.md` or `CLAUDE.md` wins over any rule here.
