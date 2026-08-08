# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> This file is the canonical AI context for the repo. `AGENTS.md` is a symlink to it — edit only `CLAUDE.md`.

## 1. Commands

All commands are Melos-scoped and run from the repo root (FVM-managed Flutter, see `.fvmrc`).

| Task | Command |
|------|---------|
| Bootstrap workspace (link all packages) | `melos run refresh` (or `melos bootstrap`) |
| Install deps after pubspec changes | `melos run get` |
| Codegen (Drift, JsonSerializable, build_runner) | `melos run generate` |
| Drift migration generation | `melos run generate:migration` |
| Lint / analyze all packages | `melos run analyze` |
| Run all tests (all packages) | `melos run test` |
| Run a single test | `fvm flutter test test/<file>_test.dart` (from the module dir) |
| Run the app | `fvm flutter run` |
| Merged coverage report (lcov + cobertura) | `melos run coverage:merged` (open with `coverage:merged:open`) |

Notes:
- Run `melos run generate` after modifying any table, model, or API interface to refresh `*.g.dart` files. `*.g.dart` is excluded from analysis in `analysis_options.yaml`.
- After adding a new module or changing a package's deps, run `melos run refresh` — it cleans, bootstraps, and re-links the whole workspace.
- Lint rules enforced globally via `analysis_options.yaml`: strict trailing commas (`require_trailing_commas`), relative imports within a package (`prefer_relative_imports`), single quotes, grouped/sorted imports (`directives_ordering`), and mandatory declared return types (`always_declare_return_types`).

## 2. Tech Stack & Environment
- **Framework**: Flutter (version managed by FVM in `.fvmrc`)
- **Language**: Dart (SDK specified in `pubspec.yaml`)
- **Monorepo Management**: [Melos](https://melos.invertase.dev/) for package orchestration.
- **State Management**: BLoC/Cubit via internal `safe_bloc` module. Uses `SafeCubit` to prevent emits after closure and `AutoSubscriptionMixin` for stream management.
- **Dependency Injection**: Custom `Registrar` pattern built on top of `GetIt` (abstracted in `service_locator` module).
- **Database**: [Drift](https://drift.simonbinder.eu/) (SQLite) for local persistence in `manga_service_drift`. Uses cross-platform `Executor` for Web/IO support.
- **Networking**: [Dio](https://pub.dev/packages/dio) for API requests in `core_network`.
- **Routing**: [go_router](https://pub.dev/packages/go_router) in `core_route`.
- **Linting**: Rules enforced via `analysis_options.yaml` (see §1).

## 3. Architecture & Directory Structure
The project follows a **Modular Clean Architecture** pattern with a sharded directory structure in `module/`:
- **root (`/`)**: Main entry point (`lib/main.dart`) where `WrapperScreen` handles global service registration.
- **`module/entity/`**: Pure data models and value objects (`entity_manga`) plus scraped-source DTOs (`entity_manga_external`).
- **`module/domain/`**: Business logic, use cases, and repository interfaces (`domain_manga`).
- **`module/core/`**: Infrastructure and cross-cutting concerns (Auth, Route, Network, Storage, Analytics, Environment). `core_storage` wires the database, DAOs, and caches.
- **`module/library/`**: Internal utility libraries and 3rd-party wrappers (Drift service, Service Locator, BLoC, MangaDex API, Firebase).
- **`module/ui/`**: Reusable UI components, themes, and shared widgets (`ui_common`). Feature-specific UI modules (e.g., `ui_browse`) contain both Screens and their colocated Cubits.
- **`module/feature/`**: High-level feature orchestration and routing. Bridges UI with Domain and Core; the only layer that knows navigation.

**Big-picture wiring to understand before editing:**
- **Bootstrap order is load-bearing.** `lib/main.dart` → `WrapperScreen` → `locatorBuilder()` runs `locator.reset()`, registers registrars sequentially (CoreAnalytics first, then CoreStorage, CoreNetwork, CoreEnvironment, CoreRoute, DomainManga), then awaits `locator.allReady()`. Circular dependencies between registrars cause startup failures.
- **Registrar/Initiator pattern**: every module exposes a `Registrar` (library modules use the `Initiator` alias) that registers its services into the shared `ServiceLocator` (GetIt-backed). Interfaces are registered via `alias<Interface, Manager>()` — e.g. `PathManager` implements `GetRootPathUseCase`/`GetBackupPathUseCase`/`GetDownloadPathUseCase`.
- **Data flow**: `core_network` (Dio + headless WebView scraping) and `manga_dex_api` (MangaDex REST) feed `domain_manga` use cases, which sync into Drift DAOs (`manga_service_drift` via `core_storage`) and cache managers. UI modules consume use cases via `locator()`, never services directly.
- **Scraping sources**: `SourceExternal` (in `entity_manga_external`) defines a plugin contract for non-MangaDex sources (e.g. AsuraScan). Mangadex is `builtIn` and goes through `manga_dex_api`; its source use-case getters `throw UnimplementedError()`.
- **UI convention**: `ui_*` screens are pure widgets that take `onTapX`/`onTapY` callbacks and a static `create(locator:, ...)` factory; `feature_*` route builders supply navigation via `BaseRouteBuilder` (`root()`, `routes()`, aggregated in `lib/main_route.dart`).
- **Gotcha — orphaned auth module**: `CoreAuthRegistrar` is *not* registered in `lib/main.dart` (there is a `// TODO: register module registrar here` at `lib/main.dart:37`). Auth screens/use cases exist in `core_auth` but nothing wires them into the running app.
- **Gotcha — download is unimplemented**: the "Download" action is a no-op TODO across `ui_browse` and `ui_more`.
- **Web vs IO**: conditional imports select platform implementations (e.g. `PathManager` filesystem adapter — in-memory temp dir on web, app-documents dir on IO; `Executor` in `manga_service_drift`). When DB or path errors appear only on one platform, check the `adapter/` directories.

## 4. Implementation Rules
- **Consistency**: Match existing style and patterns.
- **Code Style**: Single quotes for strings, mandatory trailing commas.
- **Imports**: Grouped (Dart, Package, Relative) and sorted alphabetically. Use relative imports within the same package.
- **Type Safety**: Always declare return types for functions and methods.
- **DI Registration**: Every module MUST provide a Registrar (or Initiator) that registers its services into the ServiceLocator.
- **Generated Code**: Run `melos run generate` after modifying models, tables, or API interfaces to update `.g.dart` files.
- **Result Wrappers**: Network operations (especially in `core_network`) should return a `Result` type (`Success`/`Error`) for explicit error handling.
- **Path Abstraction**: Avoid direct file system access; use `PathManager` or dedicated use cases in `core_storage`.
- **Naming Conventions**: Models in `entity_manga_external` should be suffixed with `Scrapped` to distinguish them from official API entities.
- **Action Delegation**: UI components should delegate navigation and high-level actions via callbacks to remain agnostic of the routing table.
- **Safe BLoC**: Cubits should extend `safe_bloc`'s `Cubit` (swallows emits after close) and mix in `AutoSubscriptionMixin` (cancels tracked subscriptions before `close()`) for any external stream subscription.

## 5. Testing Conventions
- **Framework**: Standard `flutter_test`.
- **Mocks**: Use `mocktail` for behavior-driven testing.
- **E2E**: Use `patrol` for integration and finders.
- **Commands**:
    - `melos run test`: Runs all tests across all modules.
    - `melos run coverage:merged`: Generates a unified code coverage report using `lcov` and `cobertura`.
- **Test harness**: `test/extension/patrol_tester_extension.dart` provides `testScreen(...)` — sets up a GetIt locator (allowing reassignment), in-memory DB executor, mocked caches, and registers the same registrars as `main.dart`. Note it also does not register `CoreAuthRegistrar`.

## 6. Known Blockers & Troubleshooting (Self-Learning)
> **⚠️ DIRECTIVE FOR ALL FUTURE AI AGENTS:** If you encounter a new architectural blocker, undocumented workaround, or persistent bug while working in this codebase, you MUST append it to this section with troubleshooting steps before completing your task.

- **Monorepo Dependency Synchronization**
  - **Location**: Project Root / `pubspec.yaml`
  - **Context**: Updating a package's dependencies or adding a new module requires a workspace-wide refresh to link everything correctly.
  - **Troubleshooting**: Run `melos run refresh` (or `melos bootstrap`) to synchronize `pubspec.lock` files and path references.

- **Drift DAO & Code Generation**
  - **Location**: `module/library/manga_service_drift/`
  - **Context**: The database uses many DAOs and split table definitions. Code generation is required for `part 'filename.g.dart';`.
  - **Troubleshooting**: If you change a table or add a DAO, run `melos run generate`. If migrations are needed, use `melos run generate:migration`.

- **Registrar Initialization Order**
  - **Location**: `lib/main.dart`
  - **Context**: Modules are registered in a specific order within `WrapperScreen`. Circular dependencies between registrars will cause app startup failures.
  - **Troubleshooting**: Check the `WrapperScreen` locator builder in `main.dart` if services are not found or injection fails.

- **Merged Coverage Script Complexity**
  - **Location**: `melos.yaml` (`coverage:merged`)
  - **Context**: The merged coverage script uses complex `sed` commands and `lcov` to unify reports across modules.
  - **Troubleshooting**: Ensure `lcov` and `cobertura` tools are installed on the system if this script fails.

- **Database Cross-Platform Implementation**
  - **Location**: `module/library/manga_service_drift/lib/src/database/executor.dart`
  - **Context**: Uses conditional imports (`adapter/filesystem` and `adapter/query_executor`) to handle Web and IO differences.
  - **Troubleshooting**: If database errors occur on specific platforms, check the corresponding adapter files in the `adapter/` directory.

- **UI-Logic Coupling in UI Modules**
  - **Location**: `module/ui/` (e.g., `ui_browse/lib/src/browse_manga_screen/`)
  - **Context**: Screens and their business logic (Cubits) are often colocated in the same UI module rather than separate feature modules.
  - **Troubleshooting**: When looking for logic related to a specific screen, check the same directory as the screen widget for `*_cubit.dart` and `*_state.dart` files.

- **External Source Reader Selectors Drift with Site Redesigns**
  - **Location**: `module/domain/domain_manga/lib/src/sources/` (e.g. `asura_scan_source_external.dart`)
  - **Context**: AsuraScans (and other scraped sources) rebuilt their site on Astro; the chapter reader DOM changed from `div.relative.w-full > img.w-full.block.relative.z-10` to `<div data-page="n" class="w-full"><img data-page-index="n" class="w-full block">`. The old hardcoded Tailwind-class chain matched **0** images, so the reader silently showed no/incomplete pages while the web version showed all.
  - **Troubleshooting**: Symptom "app reader has fewer/missing images than the site" → the source's `getChapterImageUseCase` selector is stale. Fetch a live chapter page (`curl -A '<mobile UA>' https://asurascans.com/comics/<slug>/chapter/<n>`), inspect the reader `<img>` attributes, and update `parse`/`scripts`. Prefer stable attributes (`data-page-index`, `data-page`) over Tailwind classes — they survive redesigns. The reader also relies on the injected scroll script (`scrollIntoView`) to trigger lazy `src` population before `getHtml()` snapshots; keep that timing in sync with the container it queries.
