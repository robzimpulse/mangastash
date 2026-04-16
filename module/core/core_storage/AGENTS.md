# core_storage Context

## Purpose:
The `core_storage` module is the centralized persistence layer for the application, managing both structured data (via SQLite/Drift) and unstructured data (via File system and SharedPreferences). It provides specialized caching mechanisms for images, HTML content, and search results to optimize performance and offline availability.

## Key Components:
* **core_storage.dart**: The primary entry point exporting storage managers, use cases, and database DAOs.
* **core_storage_registrar.dart**: Handles the complex registration of the `AppDatabase`, multiple DAOs, `PathManager`, and various `CacheManager` instances into the `ServiceLocator`.
* **manager/path_manager/**: Resolves and provides system paths for root storage, backups, and downloads.
* **manager/storage_manager/**: Contains specialized cache managers (`ImagesCacheManager`, `HtmlCacheManager`, etc.) and the `CustomFileService` for handling network-to-disk transfers.
* **use_case/**: Provides high-level interfaces for file operations like picking, saving, and path retrieval.
* **manga_service_drift**: (External Library dependency) Provides the underlying SQLite schema, `AppDatabase` implementation, and DAO definitions.

## Dependencies:
* **Internal Modules**: `service_locator`, `core_analytics`, `core_network`.
* **Internal Libraries**: `manga_service_drift` (Core database logic).
* **External Packages**: `shared_preferences`, `flutter_cache_manager`, `path_provider`, `file_picker`, `dio`, `universal_io`, `permission_handler`.

## Local Conventions:
* **DAO Pattern**: Data access is strictly abstracted into individual DAOs (e.g., `MangaDao`, `FileDao`) registered as factories.
* **Specialized Caching**: Different types of data (Images, HTML, Search results) use dedicated `CacheManager` instances to allow for specific eviction policies and storage locations.
* **Path abstraction**: Direct access to the file system is discouraged; instead, components should use `GetRootPathUseCase` or `PathManager` to ensure cross-platform compatibility.
* **Asynchronous Readiness**: The `PathManager` is registered as a `LazySingletonAsync`, and the registrar implements `allReady` to ensure the file system is accessible before the app proceeds.
