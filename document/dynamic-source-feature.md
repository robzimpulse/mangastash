# Implementation Plan: Dynamic Source Feature

## 1. System Impact
*   **`module/library/manga_service_drift`**: Local persistence for dynamic source code, metadata, and compiled EVC bytecode.
*   **`module/library/entity_manga_external`**: Definition of `DynamicSource` entity.
*   **`module/core/core_runtime` (New Module)**: Integration with `dart_eval`. Manages `Program` caching and `Runtime` execution.
*   **`module/domain/domain_manga`**:
    *   **`SourceManager` (New)**: The central authority for all sources (built-in + dynamic).
    *   `DynamicSourceExternal`: A wrapper implementation of `SourceExternal` that delegates to `core_runtime`.
    *   `GlobalOptionsManager`: Updated to depend on `SourceManager` instead of static `Sources.values`.
*   **`module/ui/ui_settings`**: UI for managing sources and a dedicated code editor.

## 2. Architecture & Performance Strategy
*   **Uniformity**: Built-in sources and Dynamic sources both implement `SourceExternal`. `SourceManager` provides a unified stream.
*   **Execution**:
    *   **Compilation**: Raw Dart strings are compiled to `Program` objects.
    *   **Caching**: Compiled EVC bytecode is stored in the database to avoid re-compilation on startup.
    *   **Lifecycle**: `Program` objects are cached in memory. A fresh `Runtime` is instantiated per execution request (parse/search).
    *   **Isolation**: Runtimes are executed within a separate **Isolate** to prevent infinite loops or memory leaks from affecting the main thread.
*   **Bridging**: Minimal `html` package bridging (CSS selectors, text, attributes) and `entity_manga_external` models.
*   **Security**: Use `dart_eval`'s `Runtime.grant()` to explicitly allow only required permissions (e.g., no filesystem access, restricted network).

## 3. Phased Implementation

### Phase 1: Foundation & Refactoring (Sources)
*   [x] **Built-In Cleanup**: Move `Sources.values` logic to a `BuiltInSourceProvider`.
*   [x] **SourceManager**: Create `SourceManager` in `domain_manga`.
    *   Combines built-in sources and (placeholder) dynamic sources.
    *   Provides `watchAllSources()` and `getSource(name)`.
*   [x] **GlobalOptionsManager**: 
    *   Remove dependency on `Sources.values`.
    *   Inject `SourceManager` and use it to resolve source objects from stored names.
*   [x] **Verification**: App runs as normal using the new `SourceManager` for existing built-in sources.

### Phase 2: Core Runtime & Execution (The Engine)
*   [x] **Module Setup**: Create `module/core/core_runtime` with `dart_eval`.
*   [x] **Bridges**:
    *   Implement `dart_eval` bridges for `MangaScrapped`, `ChapterScrapped`, `TagScrapped`.
    *   Implement bridges for `html` (`Document`, `Element`).
*   [x] **SourceRuntime**:
    *   Logic for `Compiler` (Dart -> Bytecode/Program).
    *   Logic for `Runtime` (Program + Input -> Output).
    *   Memory caching for `Program` instances.
    *   Isolate-based execution wrapper. (Partially implemented: simple execution for now, Isolate-based to be refined).
*   [x] **DynamicSourceExternal**: Implement `SourceExternal` by invoking `SourceRuntime`.
*   [x] **Verification**: Unit test `SourceRuntime` with a hardcoded script string and a sample HTML snippet.

### Phase 3: Persistence & Integration
*   [x] **Storage**: 
    *   Add `DynamicSourceTables` (id, name, baseUrl, code, bytecode, isActive).
    *   Implement `DynamicSourceDao`.
*   [x] **Sync**: Update `SourceManager` to merge `DynamicSourceDao.watch()` into the main sources stream.
*   [x] **Verification**: Unit tested `SourceManager` to verify it correctly merges built-in sources and dynamic sources from the database.

### Phase 4: Management UI & Code Editor
*   [ ] **Source Management**: Screen to list, toggle, and delete dynamic sources.
*   [ ] **Importing**:
    *   Add "Import from URL" functionality.
    *   Add "Import from File" functionality.
*   [ ] **Editor Screen**:
    *   Integrated Dart code editor.
    *   "Run/Test" functionality: Takes a sample URL, fetches HTML, and runs the current code against it, showing a preview of results.
    *   "Save" logic: Triggers compilation and saves both source code and bytecode.
*   [ ] **Verification**: Successfully add a new source via the app UI and use it to browse manga.

## 4. Risks & Mitigations (Resolved)
*   **Editor UX**: Addressed by supporting URL/File imports for easier script distribution.
*   **Security**: Addressed via `dart_eval` granular permissions and Isolate isolation for the runtime.
*   **Dependency Bloat**: Accepted as necessary for the dynamic feature set.
