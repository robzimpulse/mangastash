# ui_updates Context

## Purpose:
The `ui_updates` module is responsible for rendering the user interfaces related to manga updates and reading history. It displays lists of recently updated chapters and previously read manga, providing visual components for interacting with these domains.

## Key Components:
* **manga_updates_screen/**: Contains the `MangaUpdatesScreen`, which displays a list of the latest chapter updates, including functionality to prefetch chapters.
* **manga_history_screen/**: Contains the `MangaHistoryScreen`, which visualizes the user's reading history, allowing them to revisit previously read manga and chapters.
* **manga_updates_screen_cubit.dart** (and similar for history): BLoC implementations responsible for managing the state and business logic specific to each screen, interacting with domain use cases.

## Dependencies:
* **Core Modules**: `core_storage` (for image caching).
* **Domain Modules**: `domain_manga` (for listening to unread history and prefetching).
* **UI Modules**: `ui_common` (for shared UI components like `ScaffoldScreen`, `ChapterTileWidget`).
* **Library**: `service_locator`, `safe_bloc`.
* **External Packages**: `flutter/material.dart`.

## Local Conventions:
* **BLoC-based State Management**: Each screen within this module utilizes a dedicated BLoC (Cubit) for managing its UI state and handling interactions with the domain layer.
* **Static Factory Injection**: Screens are instantiated via a static `.create({required ServiceLocator locator, ...})` method, which handles the provision of their respective BLoCs and other dependencies.
* **Callback-driven Actions**: User interactions and navigation events are communicated upwards to the feature layer through callbacks (`onTapManga`, `onTapChapter`), maintaining a clear separation between UI and orchestration logic.
* **Common UI Reusability**: Makes extensive use of general-purpose UI components from `ui_common` to ensure consistency and reduce redundancy.
