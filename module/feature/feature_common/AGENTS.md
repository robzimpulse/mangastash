# feature_common Context

## Purpose:
The `feature_common` module provides shared routing and navigation components that are used across multiple features of the application. It centralizes common UI interactions such as confirmation dialogs and context menus (e.g., manga or image menus) to ensure a consistent user experience.

## Key Components:
* **feature_common.dart**: The primary library entry point exporting shared routing utilities.
* **route_path.dart**: Defines the URL structure and query parameter constants for shared screens and bottom sheets (e.g., `/confirmation`, `/menu/manga`).
* **route_builder.dart**: Implements `BaseRouteBuilder` to define global `GoRouter` configurations for common UI elements like `ConfirmationRouteBottomSheet` and `MangaMenuRouteBottomSheet`.

## Dependencies:
* **Core Modules**: `core_route`, `core_network`, `core_environment`.
* **UI Modules**: `ui_common`.
* **Library**: `service_locator`.

## Local Conventions:
* **Aggregation Only**: Unlike feature-specific modules, `CommonRouteBuilder` does not define a `root` route (throwing `UnimplementedError`) as its routes are intended to be mixed into other feature flows or called globally.
* **Query-Driven State**: Passes UI configuration (like button text or titles) via `queryParameters` in the route path to decouple the trigger from the UI implementation.
* **Modal Consistency**: Standardizes the use of bottom sheets for common actions (menus, confirmations) across the app by providing reusable `GoRoute` definitions.
