# entity_manga_external Context

## Purpose:
The `entity_manga_external` module defines the data structures and abstract interfaces for manga content retrieved from external sources through scraping. It acts as a bridge for non-official or third-party sources, providing a standardized way to represent "scrapped" manga, chapters, and tags while defining the contract for external source implementations.

## Key Components:
* **manga_scrapped.dart**: Data model representing manga information extracted from an external web source.
* **chapter_scrapped.dart**: Data model for chapter-level details, including image URL lists for the reader, parsed from external HTML.
* **tag_scrapped.dart**: Data model for manga tags/genres obtained from external sources.
* **source_external.dart**: Defines the `SourceExternal` abstract class and its associated use case interfaces (`GetMangaSourceExternalUseCase`, `SearchMangaSourceExternalUseCase`, etc.), which any web-scraping source must implement.

## Dependencies:
* **Internal Modules**: `manga_dex_api` (used for common parameters like `SearchMangaParameter`).
* **External Packages**: `equatable` (for value equality in models), `html` (for DOM element types in use case interfaces).
* **Flutter**: `sdk: flutter`.

## Local Conventions:
* **Scrapped Naming Convention**: Models are suffixed with `Scrapped` to clearly distinguish them from official API entities or internal domain entities.
* **Interface-Driven Scraping**: Scraping logic is decentralized into use cases defined within the `SourceExternal` contract, allowing for flexible implementation of different website parsers.
* **Value Objects**: Models extend `Equatable` to facilitate easy comparison and state management downstream in the feature and UI layers.
* **HTML Integration**: The use case interfaces directly accept `Document` objects from the `html` package, signaling that implementations are expected to perform DOM traversal for data extraction.
