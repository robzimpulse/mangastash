# entity_manga Context

## Purpose:
The `entity_manga` module defines the core data structures and domain models for the application. It provides platform-agnostic representations of manga, chapters, tags, and their associated configurations, serving as the common language between the domain, data, and UI layers.

## Key Components:
* **manga.dart**: Defines the primary `Manga` entity, including metadata like title, description, cover image, status, and associated tags.
* **chapter.dart**: Represents a single `Chapter` within a manga, tracking volume/chapter numbers, release dates, and read progress.
* **tag.dart**: Models categories and genres associated with manga.
* **enum/**: Contains essential domain enumerations such as `ChapterSortOption`, `DownloadOption`, and `MangaMenuEnum` to ensure type-safe state transitions.
* **source_search_parameter.dart**: Defines structured objects for passing search queries and filters to external manga sources.
* **manga_chapter.dart**: A composite entity typically used for operations involving both a manga and its specific chapter data.

## Dependencies:
* **Internal Core**: `core_environment`.
* **Internal Library**: `manga_dex_api`, `manga_service_drift`, `entity_manga_external`.
* **External Packages**: `equatable` (for value equality), `json_annotation` (for serialization), `collection`.

## Local Conventions:
* **Value Object Pattern**: Uses `Equatable` for all entity classes to facilitate efficient state comparison in BLoCs and UI components.
* **Serialization**: Relies on `json_serializable` (`.g.dart` files) to handle mapping between raw JSON from APIs/Database and domain entities.
* **Immutability**: Entities are designed to be immutable, using `copyWith` patterns for state updates.
* **Granular Enums**: Prefers specific enumerations for UI interactions and sorting logic to maintain clean separation from raw string data.
