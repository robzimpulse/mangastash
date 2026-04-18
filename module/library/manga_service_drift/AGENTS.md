# manga_service_drift Context

## Purpose:
The `manga_service_drift` module serves as the persistence layer for the MangaStash application, utilizing the Drift (formerly Moor) library. It defines the database schema, manages migrations, and provides Data Access Objects (DAOs) for interacting with manga-related entities like chapters, history, and library collections.

## Key Components:
* **src/database/database.dart**: The central `AppDatabase` class that orchestrates table registrations, DAO associations, and schema migration strategies.
* **src/tables/**: Contains table definitions for entities like `MangaTables`, `ChapterTables`, `LibraryTables`, `TagTables`, and more.
* **src/dao/**: Implements specialized Data Access Objects (e.g., `MangaDao`, `ChapterDao`) to encapsulate complex SQL queries and CRUD operations.
* **src/model/**: Provides data models and extensions that bridge the gap between Drift's generated classes and application-level domain entities.
* **src/database/executor.dart**: Defines the `Executor` interface for platform-specific database connection handling (IO vs. Web vs. Memory).
* **src/util/database_viewer.dart**: Provides utility for inspecting the database content, likely for debugging purposes.

## Dependencies:
* **External Packages**: `drift` (ORM), `sqlite3`, `path`, `uuid`, `file`, `collection`.
* **Internal Modules**: Often used by `core_storage` or domain modules requiring direct persistence access.

## Local Conventions:
* **DAO Pattern**: Business logic for database interactions is strictly encapsulated within DAOs to keep the main database class clean.
* **Step-by-Step Migrations**: Uses `MigrationStrategy` with `stepByStep` to ensure reliable schema upgrades across versions.
* **Platform-Independent Execution**: Uses an `Executor` abstraction to allow the database to run on mobile (SQLite), web (IndexedDB), or in-memory for testing.
* **Model Separation**: Maps database-specific row classes to more user-friendly model classes where necessary.
