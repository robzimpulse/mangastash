# service_locator Context

## Purpose:
The `service_locator` module provides a unified abstraction for dependency injection across the MangaStash application. It wraps the `get_it` library to provide a consistent interface for registering and retrieving services, factories, and singletons, while facilitating modular dependency registration through the `Registrar` pattern.

## Key Components:
* **service_locator.dart**: Defines the primary abstract interface for the service locator, including methods for synchronous and asynchronous registration and retrieval.
* **service_locator_get_it.dart**: The concrete implementation of `ServiceLocator` using the `get_it` package.
* **service_locator_registrar.dart**: Defines the `Registrar` and `Initiator` base classes, allowing modules to encapsulate their own dependency registration logic.
* **service_locator_initiator.dart**: Manages the global initialization of the service locator implementation factory.
* **service_locator_extension.dart**: Provides helpful extensions such as `alias` for type redirection and `getOrNull` for optional dependency retrieval.

## Dependencies:
* **External Packages**: `get_it` (underlying DI engine), `lazy_evaluation` (for deferred initialization), `async`, `collection`.
* **Flutter**: `sdk: flutter`.

## Local Conventions:
* **Registrar Pattern**: Each module should provide a class extending `Registrar` to handle its own dependency registration, ensuring modularity and clean separation of concerns.
* **Type Aliasing**: Use the `alias<Interface, Implementation>()` extension to decouple code from concrete implementations, favoring programming to interfaces.
* **Safe Retrieval**: Use `getOrNull` or the callable class syntax (e.g., `locator<Type>()`) for idiomatic dependency access.
* **Lazy Initialization**: Leverages `lazy_evaluation` and `registerLazySingleton` to optimize application startup time by deferring object creation until first use.
