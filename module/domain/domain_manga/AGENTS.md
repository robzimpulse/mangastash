# domain_manga Context

## Purpose:
The `domain_manga` module encapsulates the core business logic for manga management, acting as the bridge between feature-level UI and underlying data services. It is responsible for orchestrating operations related to manga discovery, chapter management, reading history, and personal library tracking across various sources.

## Key Components:
* **domain_manga.dart**: Public API and export file for all domain use cases and the registrar.
* **domain_manga_registrar.dart**: Handles the DI registration of all domain-level managers and use cases into the `ServiceLocator`.
* **src/use_case/**: Contains granular business logic organized by domain entity:
    * `manga/`: Fetching details, searching, and filtering.
    * `chapter/`: Retrieving lists, page data, and tracking read status.
    * `library/`: Managing the user's saved collection.
    * `history/`: Tracking and retrieving recently read manga.
    * `source/`: Managing various manga providers and extensions.
* **src/manager/**: Higher-level orchestrators that coordinate state across multiple use cases or external APIs.
* **src/sources/**: Implementation logic for interfacing with specific manga provider protocols.

## Dependencies:
* **Internal Core**: `core_analytics`, `core_network`, `core_environment`, `core_storage`.
* **Internal Entity**: `entity_manga`.
* **Internal Library**: `service_locator`, `manga_dex_api`, `entity_manga_external`.
* **External Packages**: `rxdart`, `html`, `collection`, `uuid`, `universal_io`.

## Local Conventions:
* **Strict Clean Architecture**: Business logic is strictly isolated from UI and data fetching implementations via the Use Case pattern.
* **Reactive Data Streams**: Leverages `rxdart` to provide reactive updates to the UI, particularly for library status and download progress.
* **Source Abstraction**: Provides a unified domain model (`entity_manga`) that masks the complexities and differences between various external manga sources.
* **Modular Injection**: Every use case is registered as a factory or singleton via the `Registrar`, ensuring dependencies are resolved through the `ServiceLocator`.
