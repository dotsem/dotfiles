---
paths:
  - "**/*.dart"
  - "**/pubspec.yaml"
---

# Flutter / Dart

- `environment.sdk` in pubspec is the Dart SDK version, not Flutter's.
- Target the latest or second-latest stable Flutter. No legacy syntax or backports.
- Run `flutter analyze` after changes and fix all warnings.
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
