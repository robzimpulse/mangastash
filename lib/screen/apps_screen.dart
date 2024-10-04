import 'package:core_environment/core_environment.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:ios_willpop_transition_theme/ios_willpop_transition_theme.dart';
import 'package:ui_common/ui_common.dart';

class AppsScreen extends StatelessWidget {
  final RouterConfig<Object>? routerConfig;

  final ListenThemeUseCase listenThemeUseCase;

  const AppsScreen({
    super.key,
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

  // taken from https://rydmike.com/flexcolorscheme/themesplayground-latest/
  ThemeData _themeLight() {
    return FlexThemeData.light(
      scheme: FlexScheme.outerSpace,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        appBarBackgroundSchemeColor: SchemeColor.primary,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );
  }

  // taken from https://rydmike.com/flexcolorscheme/themesplayground-latest/
  ThemeData _themeDark() {
    return FlexThemeData.dark(
      scheme: FlexScheme.outerSpace,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        outlinedButtonSchemeColor: SchemeColor.onPrimary,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
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
          theme: _themeLight().copyWith(pageTransitionsTheme: _transition()),
          darkTheme: _themeDark().copyWith(pageTransitionsTheme: _transition()),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) => ResponsiveBreakpoints.builder(
            breakpoints: const [
              Breakpoint(start: 0, end: 450, name: MOBILE),
              Breakpoint(start: 451, end: 800, name: TABLET),
              Breakpoint(start: 801, end: 1920, name: DESKTOP),
              Breakpoint(start: 1921, end: double.infinity, name: '4K'),
            ],
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
