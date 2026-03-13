# GEMINI.md

This file provides guidance to Gemini Code (gemini.ai/code) when working with code in this repository.

## Project Overview

MangaStash is a multi-platform manga reader application using a modular monorepo architecture managed by Melos. The project supports iOS, Android, and Web platforms with Flutter 3.32.8.

### Tech Stack
- **Framework:** Flutter 3.32.8 (pinned via FVM)
- **Language:** Dart
- **Monorepo Management:** Melos
- **State Management:** BLoC (via `safe_bloc`)
- **Dependency Injection:** `service_locator`
- **Routing:** `go_router` (via `core_route`)
- **Database:** SQLite (via `manga_service_drift`)
- **Logging:** `logger` (via `core_analytics`)
- **Networking:** Retrofit
- **Testing:** flutter_test, mocktail, Patrol (E2E)

## Build Commands

**Initial Setup:**
```bash
# Install melos globally
dart pub global activate melos 6.2.0

# Bootstrap the project (install all dependencies)
melos refresh
```

**Code Generation:**
```bash
# Generate all .g.dart files (for build_runner)
melos generate

# Generate for a sqlite database migration
melos generate:migration
```

**Running the App:**
```bash
flutter run
```

## Testing

**Mocks:** Use `mocktail` for creating mocks in tests.

**Run all unit tests:**
```bash
melos test
```

**Run unit tests with coverage:**
```bash
melos coverage:merged
```

**Run tests for a specific module with coverage:**
```bash
melos coverage
```

**Run a single test file:**
```bash
# Without simulator
melos run test <test_file_name>.dart

# With iOS simulator
melos run test <test_file_name>.dart ios

# With Android emulator
melos run test <test_file_name>.dart android
```

detailed command definition can be found on `melos.yaml`

## Architecture

### Module Structure

The codebase follows Clean Architecture with modules organized in `module/` by layer:

- **entity/** - Data models and DTOs (e.g., `entity_manga`)
- **domain/** - Use cases and business logic interfaces (e.g., `domain_manga`)
- **feature/** - Feature-specific business logic and state management (e.g., `feature_browse`, `feature_detail`, `feature_history`, `feature_library`, `feature_search`, `feature_setting`)
- **ui/** - UI components, screens, and widgets (e.g., `ui_common`, `ui_browse`, `ui_more`, `ui_updated`)
- **core/** - Cross-cutting concerns (e.g., `core_analytics`, `core_environment`, `core_network`, `core_route`, `core_storage`, `core_auth`)
- **library/** - Shared utilities and third-party wrappers (e.g., `manga_dex_api`, `manga_service_drift`, `manga_service_firebase`, `safe_bloc`, `service_locator`)


### Dependency Injection

Dependencies are registered via `ServiceLocator` (GetIt wrapper) in `service_locator`. Each module can provide a `Registrar` class that registers its dependencies:

```dart
class DomainProductRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    locator.registerLazySingleton(() => SomeUseCase(dep: locator()));
    locator.alias<SomeInterface, SomeUseCase>();
  }
}
```

The main registration happens in closure `locatorBuilder` which is called from `lib/main.dart`.

### State Management

Uses BLoC pattern with `safe_bloc` (custom wrapper around flutter_bloc). Cubits are provided via `BlocProvider` in the widget tree.

### Routing

Uses `go_router` with routes defined per feature module. The main router is built in `lib/main_route.dart` that will be called from `initState` in `lib/screen/apps_screen.dart`.

## Code Style

Key lint rules enforced (see `analysis_options.yaml`):

## Key Files
- `melos.yaml`: Monorepo configuration and script definitions.
- `pubspec.yaml`: Root dependencies and workspace configuration.
- `analysis_options.yaml`: Static analysis and linting rules.
- `.fvmrc`: Pinned Flutter version (3.24.5).
- `GEMINI.md`: Bridge file for Gemini AI agent.