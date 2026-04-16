# core_environment Context

## Purpose:
The `core_environment` module manages global application state related to the user's environment, including themes, locales, and timezones. It provides a reactive infrastructure for observing and updating these settings across the application.

## Key Components:
* **core_environment.dart**: The primary library file that exports environment-related use cases, managers, and the registrar.
* **core_environment_registrar.dart**: Handles the asynchronous registration of `ThemeManager`, `LocaleManager`, and `DateManager` into the `ServiceLocator`, ensuring they are ready before the app continues.
* **manager/**: Contains implementations for managing state and persistence for specific environment domains (`ThemeManager`, `LocaleManager`, `DateManager`).
* **use_case/**: Provides granular interfaces for interacting with environment settings, such as `ListenThemeUseCase`, `UpdateLocaleUseCase`, and `ListenCurrentTimezoneUseCase`.
* **enum/**: Defines standard enumerations for environment states, such as theme modes or supported locales.

## Dependencies:
* **Internal**: `service_locator`, `core_analytics` (for logging), `core_storage` (for persisting settings).
* **External**: `rxdart` (for reactive streams), `intl`, `flutter_timezone`, `equatable`, `package_info_plus`.

## Local Conventions:
* **Reactive Pattern**: Uses `Stream` based use cases to allow UI components to reactively update when environment settings change.
* **Asynchronous Registration**: Environment managers often require initial data from storage, so they are registered as `LazySingletonAsync` and synchronized via `allReady`.
* **Interface Segregation**: Managers implement multiple narrow "Use Case" interfaces (e.g., `ThemeManager` implements both `ListenThemeUseCase` and `UpdateThemeUseCase`) to promote clean architecture.
* **Persistence**: Relies on `core_storage` to ensure user preferences (like dark mode or language) persist across application restarts.
