# feature_updates Context

## Purpose:
The `feature_updates` module is responsible for orchestrating the "Updates" feature of the application. It manages the navigation and coordination for viewing the latest chapter updates for manga in the user's library, facilitating quick access to new content.

## Key Components:
* **feature_updates.dart**: The primary library entry point exporting routing definitions for the updates feature.
* **route_path.dart**: Defines the primary navigation path (`/updates`) for the updates screen.
* **route_builder.dart**: Implements `BaseRouteBuilder` to configure the `GoRoute` for the updates feature. It handles the logic for navigating from an update entry to either the manga detail page or directly into the manga reader.

## Dependencies:
* **Core Modules**: `core_route`.
* **Feature Modules**: `feature_browse` (for cross-feature navigation to details and reader), `feature_common`.
* **UI Modules**: `ui_updates` (contains the `MangaUpdatesScreen` implementation).
* **Entity Modules**: `entity_manga`.
* **Library**: `service_locator`, `safe_bloc`.

## Local Conventions:
* **Cross-Feature Navigation**: Leverages `BrowseRoutePath` and `BrowsePathParam` from the `feature_browse` module to ensure consistent deep-linking into manga details and the reader.
* **Screen Factory Pattern**: Uses the `.create(locator: ...)` pattern on `MangaUpdatesScreen` for dependency injection, ensuring all required BLoCs and UseCases are provided via the `ServiceLocator`.
* **Clean Separation**: Keeps the orchestration logic (routing and parameter mapping) separate from the UI implementation in `ui_updates`.
