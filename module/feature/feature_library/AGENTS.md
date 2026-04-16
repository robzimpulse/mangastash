# feature_library Context

## Purpose:
The `feature_library` module manages the user's personal collection of manga. It handles the orchestration of the library screen, allowing users to view their saved manga and providing navigation to detailed views or management menus.

## Key Components:
* **feature_library.dart**: The primary library file that exports routing definitions for the library feature.
* **route_path.dart**: Defines the primary navigation path (`/library`) for the user's collection.
* **route_builder.dart**: Implements `BaseRouteBuilder` to configure the `GoRouter` for the library. It orchestrates navigation from the library entries to manga details and handles the logic for adding new manga via a dialog.

## Dependencies:
* **Core Modules**: `core_route`.
* **Feature Modules**: `feature_browse` (for navigating to manga details), `feature_common` (for shared menus).
* **UI Modules**: `ui_browse` (contains `LibraryMangaScreen`), `ui_common` (for shared dialogs).
* **Entity Modules**: `entity_manga`.
* **Library**: `service_locator`, `safe_bloc`.

## Local Conventions:
* **Feature Interoperability**: Relies on `feature_browse` for the detailed view of manga, ensuring that the library remains focused on collection management rather than detail rendering.
* **Screen Factory Pattern**: Uses the `.create(locator: ...)` pattern on `LibraryMangaScreen` for dependency injection.
* **Modal Management**: Uses `TextFieldDialog` (from `ui_common`) to handle manual manga addition, integrated directly via the routing layer.
