# AI SYSTEM CONTEXT

## 1. Tech Stack & Environment
- **Framework**: Flutter (version managed by FVM in `.fvmrc`)
- **Language**: Dart (SDK specified in `pubspec.yaml`)
- **Monorepo Management**: [Melos](https://melos.invertase.dev/) for package orchestration.
- **State Management**: BLoC (via internal `safe_bloc` module), Provider, and RxDart.
- **Dependency Injection**: Custom `Registrar` pattern built on top of `GetIt` (abstracted in `service_locator` module).
- **Database**: [Drift](https://drift.simonbinder.eu/) (SQLite) for local persistence in `manga_service_drift`.
- **Networking**: [Dio](https://pub.dev/packages/dio) for API requests in `core_network`.
- **Routing**: [go_router](https://pub.dev/packages/go_router) in `core_route`.
- **Linting**: Rules enforced via `analysis_options.yaml`.

## 2. Architecture & Directory Structure
The project follows a **Modular Clean Architecture** pattern with a sharded directory structure in `module/`:
- **root (`/`)**: Main entry point (`lib/main.dart`), routing aggregation, and monorepo config (`melos.yaml`).
- **`module/entity/`**: Pure data models and value objects (no dependencies).
- **`module/domain/`**: Business logic, use cases, and repository interfaces.
- **`module/core/`**: Infrastructure and cross-cutting concerns (Auth, Route, Network, Storage, Analytics, Environment).
- **`module/library/`**: Internal utility libraries and 3rd-party wrappers (Drift service, Service Locator, BLoC).
- **`module/ui/`**: Reusable UI components, themes, and shared widgets (`ui_common`).
- **`module/feature/`**: High-level feature orchestration (Browse, History, Library, More, Updates). Bridges UI with Domain and Core.

## 3. Implementation Rules
- **Consistency**: Match existing style and patterns.
- **Code Style**: Single quotes for strings, mandatory trailing commas.
- **Imports**: Grouped (Dart, Package, Relative) and sorted alphabetically. Use relative imports within the same package.
- **Type Safety**: Always declare return types for functions and methods.
- **DI Registration**: Every module MUST provide a `Registrar` (or `Initiator`) that registers its services into the `ServiceLocator`.
- **Generated Code**: Run `melos run generate` after modifying models, tables, or API interfaces to update `.g.dart` files.

## 4. Testing Conventions
- **Framework**: Standard `flutter_test`.
- **Mocks**: Use `mocktail` for behavior-driven testing.
- **E2E**: Use `patrol` for integration and finders.
- **Commands**:
    - `melos run test`: Runs all tests across all modules.
    - `melos run coverage:merged`: Generates a unified code coverage report.

## 5. Known Blockers & Troubleshooting (Self-Learning)
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
  - **Context**: Modules are registered in a specific order. Circular dependencies between registrars will cause app startup failures.
  - **Troubleshooting**: Check the `WrapperScreen` locator builder in `main.dart` if services are not found or injection fails.

- **Merged Coverage Script Complexity**
  - **Location**: `melos.yaml` (`coverage:merged`)
  - **Context**: The merged coverage script uses complex `sed` commands and `lcov` to unify reports.
  - **Troubleshooting**: Ensure `lcov` and `cobertura` tools are installed on the system if this script fails.
