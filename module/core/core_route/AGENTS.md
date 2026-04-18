# core_route Context

## Purpose:
The `core_route` module provides the architectural foundation for navigation within the application. It abstracts and extends `go_router` to support a modular routing strategy, allowing different features to define their own routes while maintaining a unified navigation configuration.

## Key Components:
* **core_route.dart**: The primary library file that exports `go_router` and internal routing utilities.
* **base_route_builder.dart**: Defines the `BaseRouteBuilder` abstract class, which serves as the blueprint for feature-specific route registrations and path aggregation.
* **bottom_sheet_route.dart** & **popup_dialog_route.dart**: Provide specialized route implementations for modal UI elements like bottom sheets and dialogs.
* **core_route_registrar.dart**: A standard `Registrar` for the `ServiceLocator`, used to initialize routing-related services or managers.
* **route_action_enum.dart**: Contains enumerations for standard routing actions and transitions.

## Dependencies:
* **Internal**: `service_locator`, `core_analytics` (for logging registration events).
* **External**: `go_router`, `flutter/widgets`.

## Local Conventions:
* **Modular Routing**: Every feature module is expected to implement its own `BaseRouteBuilder`.
* **Aggregation**: The `BaseRouteBuilders` extension on `List<BaseRouteBuilder>` is used to merge routes from multiple modules into the final `GoRouter` configuration.
* **Navigation Hooks**: Supports an `onEnter` hook at the builder level, enabling global or per-module navigation guards and middleware.
* **Consistency**: Prefers structured route building over raw `GoRoute` definitions to ensure compatibility with the app's multi-platform navigation requirements (e.g., handling `rootNavigatorKey`).
