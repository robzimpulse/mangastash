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
