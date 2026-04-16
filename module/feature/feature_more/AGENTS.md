# feature_more Context

## Purpose:
The `feature_more` module handles the "More" section of the application, encompassing settings, about information, statistics, and data management. It orchestrates the navigation and logic for application-wide configurations and miscellaneous utility features.

## Key Components:
* **feature_more.dart**: The primary library entry point exporting routing definitions for the "More" and "Settings" features.
* **route_path.dart**: Centralizes the URL hierarchy and constant paths for numerous sub-settings (e.g., `/more`, `/setting`, `/setting/appearance`, `/setting/reader`).
* **route_builder.dart**: Implements `BaseRouteBuilder` to configure the complex `GoRouter` tree for the settings domain, including full-screen transitions and bottom sheets for language/country selection.

## Dependencies:
* **Core Modules**: `core_route`, `core_environment`.
* **Feature Modules**: `feature_common` (for shared confirmation dialogs).
* **UI Modules**: `ui_more` (Provides the actual screen widgets like `MoreScreen`, `SettingScreen`, and various preference screens).
* **Library**: `service_locator`, `safe_bloc`.

## Local Conventions:
* **Hierarchical Routing**: Path constants are built using string interpolation (e.g., `static const advanced = '$setting/advanced'`) to maintain a clean and logical URL structure.
* **DI via .create()**: Screens are instantiated using the static `.create(locator: ...)` pattern to ensure all necessary BLoCs and UseCases are correctly injected from the `ServiceLocator`.
* **Action Delegation**: Critical operations (like storage location changes or backup restoration) delegate user confirmation to the `feature_common` module via named routes and query parameters.
* **Modularity**: Keeps navigation and orchestration logic distinct from UI implementation, which is housed in the `ui_more` module.
