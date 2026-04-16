# core_network Context

## Purpose:
The `core_network` module acts as the central networking engine for the application, providing abstraction layers for HTTP requests and headless browser interactions. it manages the lifecycle of networking clients and provides specialized tools for scraping or interacting with web content that requires Javascript execution.

## Key Components:
* **core_network.dart**: The primary export file providing access to `Dio`, specialized adapters, and network-related use cases.
* **core_network_registrar.dart**: Handles the registration of networking services, including `DioManager` and `HeadlessWebviewManager`, into the `ServiceLocator`.
* **manager/**: Contains the implementation of networking clients (`DioManager`) and headless browser managers (`HeadlessWebviewManager`).
* **usecase/**: Defines business logic interfaces for network operations, such as `HeadlessWebviewUseCase`.
* **adapter/**: Platform-specific adapters for handling SSL certificates and other low-level network configurations.
* **response/**: Standardized result wrappers (`Result`, `Success`, `Error`) for consistent network error handling.

## Dependencies:
* **Internal**: `service_locator`, `core_analytics` (for logging).
* **External**: `dio`, `flutter_inappwebview`, `universal_io`.

## Local Conventions:
* **Lazy Registration**: Networking managers are registered as lazy singletons to conserve resources until needed.
* **Result Wrapper**: Network operations are expected to return a `Result` type to force explicit handling of success and failure states.
* **Headless Strategy**: Complex web interactions (e.g., bypassing bot detection or rendering JS) are encapsulated within `HeadlessWebviewUseCase`.
* **Environment Sensitivity**: Uses conditional exports to handle platform differences (IO vs Web) for certificate validation.
