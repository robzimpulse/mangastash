# manga_dex_api Context

## Purpose:
The `manga_dex_api` module is a dedicated library for interacting with the MangaDex REST API. it provides a structured, type-safe interface for searching manga, retrieving chapter details, fetching author information, and managing "At-Home" image server connections, abstracting the raw HTTP communication from the rest of the application.

## Key Components:
* **src/service/**: Contains Retrofit-powered service interfaces (e.g., `MangaService`, `ChapterService`, `AuthorService`) that define the API endpoints and expected responses.
* **src/repository/**: Implements repository classes (e.g., `MangaRepository`, `ChapterRepository`) that provide a higher-level API for the application, handling parameter mapping and service orchestration.
* **src/model/**: A comprehensive set of data models (DTOs) representing API requests and responses, utilizing `json_serializable` for automated JSON mapping.
* **src/enums/**: Defines type-safe enums for API-specific constants like `ContentRating`, `MangaStatus`, `LanguageCodes`, and `OrderEnums`.
* **src/exception/**: Defines custom exceptions (e.g., `ServerException`) to handle API-specific error scenarios gracefully.

## Dependencies:
* **External Packages**: `dio` (HTTP client), `retrofit` (REST client generator), `json_annotation` (JSON mapping), `equatable` (value equality).
* **Internal Modules**: Acts as a data source for domain-layer repositories in `domain_manga`.

## Local Conventions:
* **Retrofit for Networking**: All API service definitions use `retrofit` and `dio`, with generated files (`.g.dart`) handling the boilerplate implementation.
* **Repository Pattern**: Data access is funneled through repositories which act as the public API for the module, shielding consumers from raw service interfaces.
* **Granular Modeling**: Models are organized by domain entity (Manga, Chapter, Author, Cover Art) within the `model/` directory to maintain clarity in the large API surface.
* **Enum-driven Parameters**: API parameters often use custom enums with `rawValue` mappings to ensure type safety and prevent invalid request data.
