# core_analytics Context

## Purpose:
The `core_analytics` module is responsible for centralized logging and observability within the application. It provides a unified interface for capturing navigation, network, and system logs, integrating with the `LogBox` ecosystem to facilitate debugging and diagnostic capabilities.

## Key Components:
* **core_analytics.dart**: The primary public entry point that exports `LogBox` and various logger extensions (Dio, Navigation, WebView).
* **core_analytics_registrar.dart**: Handles the registration of logging services into the `ServiceLocator`, including memory and persistent storage configuration.
* **src/extension/**: Contains internal extensions for enhancing logging capabilities across different application layers.

## Dependencies:
* **Internal**: `service_locator` library.
* **External (via Git)**: `log_box`, `log_box_navigation_logger`, `log_box_dio_logger`, `log_box_in_app_webview_logger`, `log_box_persistent_storage_drift`.
* **Platform**: `package_info_plus`, `universal_io`.

## Local Conventions:
* **Registration Pattern**: Uses the `Registrar` pattern to hook into the global `ServiceLocator`, ensuring logging is available early in the app lifecycle.
* **Unified Logging**: Prefers the use of `LogBox` for all diagnostic information, including automatic capturing of network requests (via interceptors) and navigation events.
* **Diagnostic Focus**: Currently configured with a large `MemoryStorage` capacity (10,000 entries) for live session debugging, with hooks available for future drift-based persistence.
