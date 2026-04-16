# ui_more Context

## Purpose:
The `ui_more` module is responsible for rendering the user interface for the "More" and "Settings" sections of the application. It provides the visual components for managing application preferences, viewing information, and accessing utility features.

## Key Components:
* **more_screen.dart**: The main screen for the "More" tab, acting as a dashboard for accessing various settings and information.
* **setting_screen.dart**: The primary settings hub, listing various configurable options.
* **Individual Setting Screens** (e.g., `AppearanceScreen`, `DataStorageScreen`, `ReaderScreen`, `SecurityScreen`): Dedicated screens for configuring specific aspects of the application.
* **Information Screens** (e.g., `AboutScreen`, `StatisticScreen`): Screens for displaying application-related information.
* **Utility Screens** (e.g., `BrowseScreen`, `QueueScreen`, `LibraryScreen`): Screens that provide access to related utility functions or views.
* **Sub-Components**: Various custom widgets within each screen tailored for preference selection, information display, and user interaction.

## Dependencies:
* **Core Modules**: `core_analytics`, `core_route`, `core_environment`, `core_storage`, `core_network`.
* **Domain Modules**: `domain_manga`.
* **Entity Modules**: `entity_manga`.
* **Feature Modules**: `feature_common`.
* **UI Modules**: `ui_common` (for base widgets like `ScaffoldScreen`, `AdaptivePhysicListView`), `ui_updates`.
* **Library**: `service_locator`, `safe_bloc`, `flex_color_scheme`.

## Local Conventions:
* **Screen Factory Pattern**: Screens consistently use a static `.create({required ServiceLocator locator, ...})` method for dependency injection, ensuring BLoCs and use cases are properly initialized.
* **Action Delegation**: Uses callbacks (`onTap...`) to pass user interactions and navigation events up to the `feature_more` routing layer, maintaining separation of concerns.
* **BLoC for State Management**: Employed for managing screen-specific states, especially for preference selections and data fetching.
* **Theming Integration**: Integrates with `FlexColorScheme` for theming options, managed via `core_environment`.
