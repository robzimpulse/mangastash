# GEMINI.md

This file provides guidance to GEMINI Code (gemini.ai/code) when working with code in this project.

## Project Overview

manga_service_drift is a core data-persistence module. It acts as the local offline storage engine using drift (a robust SQLite wrapper for Flutter/Dart). It manages the entire local caching and state persistence layer for the application's manga data, chapters, downloaded files, reading history, and background download jobs.

## Project Architecture

The codebase follows Clean Architecture with modules organized in `lib/` by layer:
- **dao/** - Data access object (e.g., `chapter_dao`, `diagnostic_dao`)
- **database/** - Database class, executor and adapter (e.g., `database`, `executor`, `memory_executor`, `backup_database`, `restore_database`)
- **extension/** - Extension class for convenience purpose (e.g., `companion_equality`, `navigation_extension`, `nullable_generic`)
- **mixin/** - Reusable logic for specific class (e.g., `auto_id`, `auto_timestamp_table`)
- **model/** - Data models (e.g., `chapter_model`, `diagnostic_model`)
- **screen/** - Pre-build screen (e.g., `diagnostic_screen`)
- **tables/** - Database table definition (e.g., `chapter_tables`, `manga_tables`)
- **util/** - Utility class (e.g., `job_type_enum`, `database_viewer`)

### External Dependencies

The project relies on several public packages (see `pubspec.yaml`)

## Code Style

Key lint rules enforced (see `analysis_options.yaml`).

## Key Files
- `GEMINI.md`: Bridge file for Gemini AI agent.
- `pubspec.yaml`: Root dependencies and workspace configuration.
- `analysis_options.yaml`: Static analysis and linting rules.