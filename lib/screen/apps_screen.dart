import 'package:core_environment/core_environment.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:ios_willpop_transition_theme/ios_willpop_transition_theme.dart';
import 'package:responsive_framework/breakpoint.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:service_locator/service_locator.dart';

class AppsScreen extends StatelessWidget {
  final ServiceLocator locator;

  final RouterConfig<Object>? routerConfig;

  final ListenThemeUseCase listenThemeUseCase;

  const AppsScreen({
    super.key,
    required this.locator,
    required this.listenThemeUseCase,
    this.routerConfig,
  });

  PageTransitionsTheme _transition() {
    return const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: IOSWillPopTransitionsBuilder(),
        TargetPlatform.android: IOSWillPopTransitionsBuilder(),
      },
    );
  }

  ThemeData _themeLight() {
    final theme = FlexThemeData.light(scheme: FlexScheme.outerSpace);
    return theme.copyWith(
      pageTransitionsTheme: _transition(),
      splashColor: theme.primaryColor,
        colorScheme: theme.colorScheme.copyWith(
          secondary: theme.primaryColor,
        ),
    );
  }

  ThemeData _themeDark() {
    final theme = FlexThemeData.dark(scheme: FlexScheme.outerSpace);

    return theme.copyWith(
      pageTransitionsTheme: _transition(),
      splashColor: theme.primaryColor,
      colorScheme: theme.colorScheme.copyWith(
        secondary: theme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeData>(
      stream: listenThemeUseCase.themeDataStream,
      builder: (context, snapshot) {
        final isDarkMode = snapshot.data?.brightness == Brightness.dark;
        return MaterialApp.router(
          title: 'Manga Stash',
          debugShowCheckedModeBanner: false,
          routerConfig: routerConfig,
          theme: _themeLight(),
          darkTheme: _themeDark(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            return ResponsiveBreakpoints.builder(
              breakpoints: const [
                Breakpoint(start: 0, end: 450, name: MOBILE),
                Breakpoint(start: 451, end: 800, name: TABLET),
                Breakpoint(start: 801, end: 1920, name: DESKTOP),
                Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
