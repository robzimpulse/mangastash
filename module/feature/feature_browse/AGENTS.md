# feature_browse Context

## Purpose:
The `feature_browse` module serves as the navigation and orchestration layer for the manga discovery domain. It defines the routing structure, path parameters, and screen transitions required for browsing sources, searching for manga, and viewing detailed content.

## Key Components:
* **feature_browse.dart**: The primary library entry point that exports routing definitions for consumption by the main application.
* **route_path.dart**: Centralizes the URL structure and parameter constants (e.g., `source`, `mangaId`, `chapterId`) used for navigation within the browse feature.
* **route_builder.dart**: Implements the `BaseRouteBuilder` to define `GoRouter` configurations, mapping paths to specific screens and orchestrating navigation logic between them.

## Dependencies:
* **Core Modules**: `core_route`, `core_network`, `core_environment`.
* **Domain Modules**: `domain_manga`.
* **Entity Modules**: `entity_manga`.
* **UI Modules**: `ui_browse` (Provides the actual screen widgets like `BrowseSourceScreen`, `MangaDetailScreen`).
* **Feature Modules**: `feature_common` (For shared menus and universal routes).
* **Library**: `service_locator`, `safe_bloc`.

## Local Conventions:
* **Routing-Driven Design**: This module focuses on "how to get there" rather than "what it looks like," delegating UI implementation to the `ui_browse` package.
* **DI via .create()**: Screens are instantiated using a static `.create(locator: ...)` pattern to ensure all necessary BLoCs and UseCases are correctly injected.
* **Structured Navigation**: Uses dedicated classes for `PathParams` and `QueryParams` to prevent string-typing errors during navigation.
* **Shell & Full-Screen Transitions**: Distinguishes between sub-routes within the main shell and full-screen navigations (using `rootNavigatorKey`) for immersive experiences like the manga reader.
