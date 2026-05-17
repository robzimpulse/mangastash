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
    *   **Lifecycle**: `Program` objects are cached in memory. A fresh `Runtime` is instantiated per execution request (parse/search) to ensure isolation and prevent memory leaks.
*   **Bridging**: Minimal `html` package bridging (CSS selectors, text, attributes) and `entity_manga_external` models.

## 3. Phased Implementation

### Phase 1: Foundation & Refactoring (Sources)
*   [ ] **Built-In Cleanup**: Move `Sources.values` logic to a `BuiltInSourceProvider`.
*   [ ] **SourceManager**: Create `SourceManager` in `domain_manga`.
    *   Combines built-in sources and (placeholder) dynamic sources.
    *   Provides `watchAllSources()` and `getSource(name)`.
*   [ ] **GlobalOptionsManager**: 
    *   Remove dependency on `Sources.values`.
    *   Inject `SourceManager` and use it to resolve source objects from stored names.
*   [ ] **Verification**: App runs as normal using the new `SourceManager` for existing built-in sources.

### Phase 2: Core Runtime & Execution (The Engine)
*   [ ] **Module Setup**: Create `module/core/core_runtime` with `dart_eval`.
*   [ ] **Bridges**:
    *   Implement `dart_eval` bridges for `MangaScrapped`, `ChapterScrapped`, `TagScrapped`.
    *   Implement bridges for `html` (`Document`, `Element`).
*   [ ] **SourceRuntime**:
    *   Logic for `Compiler` (Dart -> Bytecode/Program).
    *   Logic for `Runtime` (Program + Input -> Output).
    *   Memory caching for `Program` instances.
*   [ ] **DynamicSourceExternal**: Implement `SourceExternal` by invoking `SourceRuntime`.
*   [ ] **Verification**: Unit test `SourceRuntime` with a hardcoded script string and a sample HTML snippet.

### Phase 3: Persistence & Integration
*   [ ] **Storage**: 
    *   Add `DynamicSourceTables` (id, name, baseUrl, code, bytecode, isActive).
    *   Implement `DynamicSourceDao`.
*   [ ] **Sync**: Update `SourceManager` to merge `DynamicSourceDao.watch()` into the main sources stream.
*   [ ] **Verification**: Manually insert a record into the DB and verify it appears in the "Sources" selection UI.

### Phase 4: Management UI & Code Editor
*   [ ] **Source Management**: Screen to list, toggle, and delete dynamic sources.
*   [ ] **Editor Screen**:
    *   Integrated Dart code editor.
    *   "Run/Test" functionality: Takes a sample URL, fetches HTML, and runs the current code against it, showing a preview of results.
    *   "Save" logic: Triggers compilation and saves both source code and bytecode.
*   [ ] **Verification**: Successfully add a new source via the app UI and use it to browse manga.

## 4. Open Questions & Risks
*   **Editor UX**: Writing code on a mobile device is difficult. Should we support importing scripts via URL/File?
*   **Security**: `dart_eval` is a sandbox, but we should define clear boundaries on what host APIs the scripts can access.
*   **Dependency Bloat**: `dart_eval` and the compiler might increase APK size. Monitor the `core_runtime` footprint.
