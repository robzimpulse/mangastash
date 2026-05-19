# AI SYSTEM CONTEXT

## 1. Tech Stack & Environment
- **Framework**: Flutter (version managed by FVM in `.fvmrc`)
- **Language**: Dart (SDK specified in `pubspec.yaml`)
- **Monorepo Management**: [Melos](https://melos.invertase.dev/) for package orchestration.
- **State Management**: BLoC/Cubit via internal `safe_bloc` module. Uses `SafeCubit` to prevent emits after closure and `AutoSubscriptionMixin` for stream management.
- **Dependency Injection**: Custom `Registrar` pattern built on top of `GetIt` (abstracted in `service_locator` module).
- **Database**: [Drift](https://drift.simonbinder.eu/) (SQLite) for local persistence in `manga_service_drift`. Uses cross-platform `Executor` for Web/IO support.
- **Networking**: [Dio](https://pub.dev/packages/dio) for API requests in `core_network`.
- **Routing**: [go_router](https://pub.dev/packages/go_router) in `core_route`.
- **Linting**: Rules enforced via `analysis_options.yaml` (strict trailing commas, relative imports, single quotes).

## 2. Architecture & Directory Structure
The project follows a **Modular Clean Architecture** pattern with a sharded directory structure in `module/`:
- **root (`/`)**: Main entry point (`lib/main.dart`) where `WrapperScreen` handles global service registration.
- **`module/entity/`**: Pure data models and value objects.
- **`module/domain/`**: Business logic, use cases, and repository interfaces.
- **`module/core/`**: Infrastructure and cross-cutting concerns (Auth, Route, Network, Storage, Analytics, Environment). `core_storage` manages the database and DAOs.
- **`module/library/`**: Internal utility libraries and 3rd-party wrappers (Drift service, Service Locator, BLoC).
- **`module/ui/`**: Reusable UI components, themes, and shared widgets (`ui_common`). Feature-specific UI modules (e.g., `ui_browse`) typically contain both the Screens and their corresponding Cubits.
- **`module/feature/`**: High-level feature orchestration and routing. Bridges UI with Domain and Core.

## 3. Implementation Rules
- **Consistency**: Match existing style and patterns.
- **Code Style**: Single quotes for strings, mandatory trailing commas.
- **Imports**: Grouped (Dart, Package, Relative) and sorted alphabetically. Use relative imports within the same package.
- **Type Safety**: Always declare return types for functions and methods.
- **DI Registration**: Every module MUST provide a Registrar (or Initiator) that registers its services into the ServiceLocator.
- **Generated Code**: Run melos run generate after modifying models, tables, or API interfaces to update .g.dart files.
- **Result Wrappers**: Network operations (especially in core_network) should return a Result type for explicit error handling.
- **Path Abstraction**: Avoid direct file system access; use PathManager or dedicated use cases in core_storage.
- **Naming Conventions**: Models in entity_manga_external should be suffixed with Scrapped to distinguish them from official API entities.
- **Action Delegation**: UI components should delegate navigation and high-level actions via callbacks to remain agnostic of the routing table.

## 4. Testing Conventions
- **Framework**: Standard `flutter_test`.
- **Mocks**: Use `mocktail` for behavior-driven testing.
- **E2E**: Use `patrol` for integration and finders.
- **Commands**:
    - `melos run test`: Runs all tests across all modules.
    - `melos run coverage:merged`: Generates a unified code coverage report using `lcov` and `cobertura`.

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

- **Dynamic Source Management (Phase 3 Complete, Phase 2 Complete)**
  - **Context**: The legacy static `Sources` class has been removed. All source resolution MUST happen via `SourceManager`. Dynamic sources are fully supported with isolate-based execution and search parameter bridging.
  - **Troubleshooting**: If search functionality fails for dynamic sources, verify the script implements `searchUrl` correctly. Check `SourceRuntime` for execution errors.
