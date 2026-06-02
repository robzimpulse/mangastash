# Custom Scraper Script Side-Loading Design

## 1. Overview
The application will allow users to side-load custom manga sources by providing a remote URL to a Dart script. These scripts will be executed in a sandboxed environment using `dart_eval`. The architecture is designed to make script writing as seamless as possible by binding `package:html` utilities and passing parsed `Document` objects directly into the scripts.

## 2. Engine Architecture & Bindings

### 2.1 Execution Engine
A dedicated `CustomScriptExecutor` will be created to manage the `dart_eval` runtime environment. It will compile the downloaded scripts and bridge communication between the native app and the sandboxed code.

### 2.2 `package:html` Bindings
To allow script authors to traverse the DOM easily, the executor will register bindings for core `package:html` classes:
*   **Functions**: `parse(String html)`
*   **Classes**: `Document`, `Element`
*   **Methods/Properties**: `querySelector`, `querySelectorAll`, `text`, `attributes`.

This enables scripts to use standard Dart DOM traversal syntax.

### 2.3 Executable Function Interface
The downloaded Dart scripts must act as a library of pure functions. The app's executor will invoke these functions by name. Note that HTML content is passed directly as a parsed `Document` object to avoid redundant parsing inside the script:

*   `Map<String, String> getMetadata()`: Called upon download to register the name, base URL, and icon.
*   `String searchMangaUrl(int page, String title, List<String> status, List<String> includedTags, String includedTagsMode)`: Constructs the search URL.
*   `List<Map<String, dynamic>> parseSearchManga(Document root)`: Parses search page results.
*   `Map<String, dynamic> parseManga(Document root)`: Parses manga details.
*   `List<Map<String, dynamic>> parseChapters(Document root)`: Parses list of chapters.
*   `List<String> parseChapterImages(Document root)`: Parses chapter image URLs.
*   `List<Map<String, dynamic>> parseTags(Document root)`: Parses available genres/tags.
*   `bool haveNextPage(Document root)`: Determines if search pagination should continue.

## 3. Storage & Domain Integration

### 3.1 Database Schema (Drift)
Side-loaded scripts will be stored transactionally in the local SQLite database via a new Drift table (e.g., `CustomSourcesTable`):
*   `id`: Auto-incrementing integer (PK).
*   `name`: Text (extracted from script metadata).
*   `baseUrl`: Text (extracted from script metadata).
*   `iconUrl`: Text (extracted from script metadata).
*   `scriptUrl`: Text (Unique URL used to fetch the script).
*   `scriptCode`: Text (Raw Dart script code).

### 3.2 Domain Layer (`CustomSourceExternal`)
A dynamic wrapper class, `CustomSourceExternal`, will implement the existing `SourceExternal` interface. 
When a native use case (like `GetMangaSourceExternalUseCase`) is executed:
1. It initializes `dart_eval` with the stored `scriptCode`.
2. It passes the `Document` object to the script's `parseManga` function.
3. It maps the returned `Map<String, dynamic>` to the native `MangaScrapped` entity.

### 3.3 Source Aggregation
`GlobalOptionsManager` will load `CustomSourcesTable` entries on startup. These dynamic sources will be instantiated as `CustomSourceExternal` objects and merged into the `Sources.values` list alongside built-in sources (MangaDex, MangaClash).

## 4. UI & Error Handling

### 4.1 User Interface
*   **Add Source**: A dialog/screen prompting the user for a remote script URL. Upon submission, the app downloads the script, automatically verifies and extracts metadata via `getMetadata()`, and saves it.
*   **Manage Sources**: A list view displaying installed custom sources, allowing users to delete or update (re-download) them.

### 4.2 Error Handling
*   **Download Phase**: Network timeouts or invalid HTTP responses will trigger a standard network error without corrupting the database.
*   **Compilation Phase**: Syntax errors or missing required functions during the `dart_eval` compilation step will be caught and surfaced as "Invalid Script" alerts to the user.
*   **Execution Phase**: Runtime exceptions thrown by the script (e.g., website layout changes causing null pointers) will be caught by the `CustomSourceExternal` wrapper and safely converted into standard `Result.failure` responses, preventing app crashes.
