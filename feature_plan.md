# Implementation Plan: Dynamic Source Feature

## 1. System Impact
*   **`module/library/manga_service_drift`**: Local persistence for dynamic source code and metadata.
*   **`module/library/entity_manga_external`**: Definition of `DynamicSource` entity.
*   **`module/core/core_runtime` (New Module)**: Integration with `dart_eval` and bridging logic for `html` and `entity_manga_external` packages.
*   **`module/domain/domain_manga`**:
    *   `DynamicSourceExternal`: A wrapper implementation of `SourceExternal` that delegates to the `dart_eval` runtime.
    *   `GlobalOptionsManager`: Updated to load and merge dynamic sources from the database.
    *   `DynamicSourceManager`: New manager for CRUD operations on dynamic sources.
*   **`module/ui/ui_settings`**: UI components for managing dynamic sources.

## 2. Data & State Flow
1.  **Persistence**: User-provided Dart/EVC code is stored in SQLite via `DynamicSourceDao`.
2.  **Initialization**: On app startup, `GlobalOptionsManager` queries `DynamicSourceDao`. It instantiates `DynamicSourceExternal` for each record and combines them with built-in sources.
3.  **Execution**: When a user selects a dynamic source:
    *   `DynamicSourceExternal` initializes a `dart_eval` `Runtime`.
    *   It passes the HTML `Document` (from the crawler) to the dynamic `parse` method.
    *   The `dart_eval` bridge translates between the host's `html` objects and the dynamic environment.
    *   Results (`MangaScrapped`, etc.) are returned to the domain layer.

## 3. Execution Checklist

### [ ] Dependencies & Interfaces
*   **New Module**: Create `module/core/core_runtime`.
*   **Dependencies**:
    *   Add `dart_eval: ^0.7.0` to `core_runtime/pubspec.yaml`.
    *   Add `entity_manga_external` and `html` to `core_runtime`.
*   **Entity**: Add `DynamicSource` model to `entity_manga_external/lib/src/dynamic_source.dart`.

### [ ] Core Logic/Backend (Storage)
*   **Table**: Create `DynamicSourceTables` in `manga_service_drift/lib/src/tables/dynamic_source_tables.dart`.
    *   Fields: `id`, `name`, `baseUrl`, `iconUrl`, `code` (Text/Blob), `createdAt`.
*   **DAO**: Implement `DynamicSourceDao` with `watchAllDynamicSources()`, `insertSource()`, `deleteSource()`.
*   **Migration**:
    *   Update `AppDatabase` in `database.dart`.
    *   Increment `schemaVersion` to `3`.
    *   Implement `from2To3` migration in `MigrationStrategy`.

### [ ] Execution Engine (Core Runtime)
*   **Bridge Generation**:
    *   Implement `dart_eval` bridges for `MangaScrapped`, `ChapterScrapped`, `TagScrapped`.
    *   Implement minimal bridges for `html` classes: `Document`, `Element`, `Attributes`.
*   **Runtime Wrapper**: Create `SourceRuntime` class to manage `Compiler` (for raw Dart strings) and `Runtime` (for EVC execution).

### [ ] Domain Integration
*   **Wrapper Implementation**: Create `DynamicSourceExternal` in `domain_manga/lib/src/sources/dynamic_source_external.dart`.
    *   It must implement all `SourceExternal` interfaces by invoking the corresponding functions in the `dart_eval` environment.
*   **Manager**: Create `DynamicSourceManager` for high-level management.
*   **GlobalOptionsManager**:
    *   Update `create()` to fetch from `DynamicSourceDao`.
    *   Use `Rx.combineLatest2` to merge built-in `Sources.values` with dynamic sources from the DAO's stream.
*   **DI**: Register new services in `DomainMangaRegistrar`.

### [ ] Presentation/UI
*   **Settings Integration**: Add "Dynamic Sources" entry in Settings.
*   **Management Screen**: List all installed dynamic sources.
*   **Editor Screen**:
    *   Add text editor for Dart code.
    *   Add "Validate/Test" button that runs the code against a sample URL.

### [ ] Testing
*   **Unit Tests**: Create a mock dynamic source script (as a string) and verify `SourceRuntime` can parse a sample HTML `Document`.
*   **Persistence Tests**: Verify `DynamicSourceDao` correctly handles large code blobs.

## 4. Architecture Questions
*   **Performance**: Compiling Dart strings on-device can be slow. Should we mandate pre-compiled `.evc` bytecode for production-ready sources?
*   **Bridge Scope**: How much of the `html` package needs to be bridged? (Recommendation: Start with `querySelector`, `querySelectorAll`, `text`, and `attributes`).
*   **Sources Refactoring**: `Sources.values` is currently a static list. How should we refactor the system to treat built-in and dynamic sources uniformly? (Proposed: move source discovery to `SourceManager`).
*   **Async Bridging**: How will we handle `Future` returns from the dynamic `parse` methods within `dart_eval`?
*   **Runtime Lifecycle**: Should we keep a long-lived `Runtime` instance per `DynamicSource` or instantiate one per request?
*   **GlobalOptionsManager Dependencies**: `GlobalOptionsManager` currently only depends on `SharedPreferences`. Adding `DynamicSourceDao` creates a dependency on the database. Is this acceptable or should we use a middle-man use case?
