# ui_common Context

## Purpose:
The `ui_common` module serves as the primary UI library and design system for the application. It provides a centralized collection of reusable widgets, base scaffolds, and navigation utilities that ensure visual consistency and responsive behavior across all feature modules.

## Key Components:
* **scaffold_screen.dart**: A foundational scaffold component used by almost all screens to maintain layout uniformity and standard behavior.
* **widget/**: A library of shared domain-specific widgets such as `MangaItemWidget`, `ChapterTileWidget`, `SourceTileWidget`, and `MangaMenuWidget`.
* **route_bottom_sheet/** & **route_popup_dialog/**: Standardized UI implementations for modal navigation elements, enabling bottom sheets and dialogs to be handled as distinct routes.
* **extension/**: Contains UI-focused extensions for `BuildContext`, `Widget`, and other Flutter classes to simplify common styling and layout tasks.
* **util/**: Reusable UI helpers, animations, and layout utility functions.

## Dependencies:
* **Internal Modules**: `core_analytics`, `core_route`, `core_environment`, `core_storage`, `core_network`, `domain_manga`, `entity_manga`.
* **Internal Libraries**: `safe_bloc`, `service_locator`, `manga_dex_api`.
* **External Packages**: `responsive_framework` (for adaptive layouts), `cached_network_image`, `expandable`, `sliver_tools`, `share_plus`.

## Local Conventions:
* **Standardized Scaffolding**: All screens are encouraged to use `ScaffoldScreen` as their root to ensure consistent padding, app bar behavior, and background styling.
* **Responsive Layouts**: Leverages `responsive_framework` to provide widgets that adapt fluidly between mobile, tablet, and desktop viewports.
* **Routing-First Modals**: Prefers wrapping complex modal interactions (like menus or confirmation dialogs) in route-aware widgets to maintain navigation state consistency.
* **Atomic Widgets**: UI is built using small, decoupled widgets that receive data via simple parameters, making them easily testable and reusable in different feature contexts.
