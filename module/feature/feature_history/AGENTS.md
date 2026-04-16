# feature_history Context

## Purpose:
The `feature_history` module is responsible for orchestrating the user's reading history feature. it manages the navigation logic for viewing recently read manga and facilitates jumping back into specific chapters within the reader.

## Key Components:
* **feature_history.dart**: The public entry point for the module, exporting routing configurations.
* **route_path.dart**: Defines the primary navigation path (`/history`) for the history feature.
* **route_builder.dart**: Implements `BaseRouteBuilder` to define the `GoRoute` for the history screen. It handles the logic for navigating from a history entry to either the manga detail page or directly into the manga reader, leveraging path parameters from `feature_browse`.

## Dependencies:
* **Core Modules**: `core_route`.
* **Feature Modules**: `feature_browse` (for cross-feature navigation to details and reader), `feature_common`.
* **UI Modules**: `ui_updates` (contains the `MangaHistoryScreen` implementation).
* **Entity Modules**: `entity_manga`.
* **Library**: `service_locator`.

## Local Conventions:
* **Cross-Feature Navigation**: Relies heavily on `BrowseRoutePath` and `BrowsePathParam` to ensure deep-linking into the browse feature (manga details and reader) is consistent with the app's overall routing structure.
* **Screen Factory Pattern**: Uses the `.create(locator: ...)` pattern on `MangaHistoryScreen` to inject required dependencies from the `ServiceLocator`.
* **Aggregation**: The module is designed to be plugged into the main app's router via its `HistoryRouteBuilder`.
