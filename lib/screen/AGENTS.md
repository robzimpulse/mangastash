# screen Context

## Purpose:
The `screen` directory contains the foundational UI components that define the application's top-level structure and lifecycle states. It manages global themes, responsive navigation layouts, and critical application states such as initialization (splash) and error handling.

## Key Components:
* **apps_screen.dart**: The primary application shell that configures `MaterialApp.router`, sets up global themes (using `FlexColorScheme`), handles responsive breakpoints, and initializes the `GoRouter` configuration.
* **main_screen.dart**: A layout wrapper that implements a responsive navigation pattern, switching between a `BottomNavigationBar` for mobile devices and a `NavigationRail` for larger screens.
* **splash_screen.dart**: A minimal entry-point screen displayed during the application's boot and dependency injection setup phase.
* **error_screen.dart**: A standardized screen for displaying fatal errors or "not found" states to the user.

## Dependencies:
* **Internal**: `../main_path.dart`, `../main_route.dart`.
* **Core Modules**: `core_route`, `core_analytics`, `core_environment`, `core_storage`.
* **UI/Common**: `ui_common` (for `ScaffoldScreen`, `ResponsiveBreakpoints`, and shared widgets).
* **External Packages**: `flex_color_scheme`, `ios_willpop_transition_theme`, `universal_io`, `service_locator`.

## Local Conventions:
* **Responsive Layouts**: Screens use `ResponsiveBreakpoints` to adapt UI elements (like navigation) dynamically based on the device's screen size.
* **Theming**: Global light and dark themes are centralized in `apps_screen.dart` using the `FlexColorScheme` package for consistent design tokens.
* **Navigation Injection**: The `main_screen.dart` receives a `child` widget from the router, acting as a "shell" route that persists navigation UI across feature transitions.
* **Error Handling**: `apps_screen.dart` provides a hook (`setupError`) to initialize crash reporting and logging observers during the widget's `initState`.
