# mangastash Context

## Purpose:
This is the root directory of the MangaStash monorepo, a multi-platform manga reader. It serves as the central orchestration point for managing multiple Flutter/Dart packages, defining project-wide configurations, and hosting the main application entry point that aggregates all modular components.

## Key Components:
* **pubspec.yaml**: Manages top-level dependencies and serves as the manifest for all internal modules, linking them via path references.
* **melos.yaml**: Configures the Melos monorepo tool, defining workspace-wide scripts for code generation, testing, and dependency synchronization.
* **lib/**: Contains the main application entry points (`main.dart`), routing configurations, and top-level screen orchestration.
* **module/**: The core of the sharded architecture, containing sub-directories for `entity`, `domain`, `feature`, `ui`, `core`, and `library` layers.
* **analysis_options.yaml**: Defines the static analysis and linting rules enforced across the entire monorepo to ensure code quality and consistency.
* **.fvmrc**: Specifies the Flutter version management configuration to ensure a consistent development environment.

## Dependencies:
* **Melos**: Used for workspace management and multi-package command execution.
* **Flutter SDK**: The primary framework for building the multi-platform application.
* **Internal Modules**: Aggregates all modules found in the `module/` directory (e.g., `core_route`, `domain_manga`, `ui_common`, etc.).

## Local Conventions:
* **Monorepo Management**: Uses Melos for managing inter-package dependencies and running unified scripts (e.g., `melos run generate`).
* **Modular Clean Architecture**: Adheres to a strict layered architecture where dependencies flow inwards (UI/Feature -> Domain -> Entity).
* **Dependency Injection**: Utilizes a `Registrar` pattern where each module is responsible for registering its own services into a central `ServiceLocator`.
* **Centralized Configuration**: Global settings like Firebase options, routing foundations, and environment setups are orchestrated from the root `lib/` directory.

## Code Style:
This project follows the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) with specific enforcements defined in `analysis_options.yaml`:
* **Single Quotes**: Prefer single quotes for strings unless the string contains a single quote.
* **Trailing Commas**: Required for function parameters, arguments, and collection literals to ensure clean diffs and consistent formatting.
* **Relative Imports**: Prefer relative imports for files within the same package to maintain modularity.
* **Type Safety**: Always declare return types for functions and methods.
* **Ordering**: Directives (imports/exports) must be ordered alphabetically and grouped (dart, package, then relative).
* **Generated Code**: Files ending in `.g.dart` are excluded from analysis as they are managed by `build_runner`.

## Setup Guidance:
To get the MangaStash project running locally, follow these steps:
1.  **Flutter Version Management**: This project uses FVM. Ensure FVM is installed and run `fvm use` in the root directory to switch to the required Flutter version (specified in `.fvmrc`).
2.  **Melos Installation**: Install Melos globally if you haven't already: `dart pub global activate melos`.
3.  **Bootstrap Workspace**: Run `melos run refresh` (or `melos bootstrap`) from the root to install dependencies across all modules and link them correctly.
4.  **Code Generation**: Many modules rely on `build_runner`. Generate the necessary code by running `melos run generate`.
5.  **Run Application**: Once bootstrapped, you can run the main application from `lib/main.dart` using your preferred IDE or command line (`fvm flutter run`).

## Agent Knowledge Base & Corrections:
This section is a living record of mistakes made by AI agents and their corresponding corrections. Future agents should review this section to avoid repeating known errors.

- **Mistake**: [Describe the mistake here]
- **Correction**: [Describe the correct instruction or behavior here]
