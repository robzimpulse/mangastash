# ui_browse Context

## Purpose:
The `ui_browse` module contains the visual representation and user interaction logic for the manga discovery and reading experience. It provides the screens, widgets, and state management (BLoCs) required to browse sources, search for manga, view details, and read chapters.

## Key Components:
* **browse_source_screen/**: The entry point for browsing available manga providers/sources.
* **browse_manga_screen/**: Displays a list or grid of manga from a specific selected source.
* **manga_detail_screen/**: Shows comprehensive information about a specific manga, including its description, tags, and chapter list.
* **manga_reader_screen/**: An immersive interface for reading manga chapters, supporting various scroll directions and image zoom.
* **search_manga_screen/**: A dedicated interface for global or source-specific manga searching.
* **library_manga_screen/**: Visualizes the user's personal collection of saved manga.
* **manga_search_param_configurator_screen/**: Provides UI for configuring complex search filters and tags.
* **widget/**: Contains module-specific reusable widgets that aren't generic enough for `ui_common`.

## Dependencies:
* **Core Modules**: `core_analytics`, `core_environment`, `core_route`, `core_network`, `core_storage`.
* **Domain Modules**: `domain_manga`.
* **Entity Modules**: `entity_manga`, `entity_manga_external`.
* **UI Modules**: `ui_common` (for shared base widgets like `ScaffoldScreen`, `AdaptivePhysicListView`).
* **Feature Modules**: `feature_common`.
* **Library**: `service_locator`, `safe_bloc`, `manga_page_view`.

## Local Conventions:
* **BLoC per Screen**: Each major screen has a corresponding Cubit/BLoC for managing its specific UI state.
* **Static Factory Pattern**: Screens implement a static `.create({required ServiceLocator locator, ...})` method that handles BLoC provision and dependency injection.
* **Action Delegation**: Screens use `Callback` or `ValueSetter` properties to delegate navigation and high-level actions back to the feature layer, keeping the UI agnostic of the global routing table.
* **Dependency on ui_common**: Leverages standardized layout components from `ui_common` to ensure a consistent look and feel across the application.
