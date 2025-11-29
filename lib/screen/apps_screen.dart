import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:ios_willpop_transition_theme/ios_willpop_transition_theme.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import '../main_path.dart';
import '../main_route.dart';

class AppsScreen extends StatefulWidget {
  final ServiceLocator locator;

  /// expose handler for setting up crash logger since overriding
  /// [PlatformDispatcher] or [FlutterError] caused issue on unit test
  final ValueSetter<LogBox> setupError;

  const AppsScreen({
    super.key,
    required this.locator,
    required this.setupError,
  });

  @override
  State<AppsScreen> createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  late final ListenThemeUseCase _listenThemeUseCase = widget.locator();

  late final RouterConfig<Object> _routerConfig;

  @override
  void initState() {
    super.initState();

    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final LogBox logBox = widget.locator();
    final DatabaseViewer viewer = widget.locator();
    _routerConfig = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: MainPath.main,
      onException: (context, state, router) {
        router.push(
          MainPath.notFound,
          extra: 'Path Not Found (${state.uri.toString()})',
        );
      },
      routes: MainRouteBuilder().allRoutes(
        locator: widget.locator,
        rootNavigatorKey: rootNavigatorKey,
        // TODO: add observer here
        observers: () => [logBox.observer],
      ),
      observers: [logBox.observer, viewer.navigatorObserver],
    );

    widget.setupError(widget.locator.get());
  }

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
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedHasBorder: false,
        appBarBackgroundSchemeColor: SchemeColor.primary,
        outlinedButtonRadius: 8,
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
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedHasBorder: false,
        outlinedButtonSchemeColor: SchemeColor.onPrimary,
        outlinedButtonRadius: 8,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeData>(
      stream: _listenThemeUseCase.themeDataStream,
      builder: (context, snapshot) {
        final isDarkMode = snapshot.data?.brightness == Brightness.dark;
        return MaterialApp.router(
          title: 'Manga Stash',
          debugShowCheckedModeBanner: false,
          routerConfig: _routerConfig,
          theme: _themeLight().copyWith(pageTransitionsTheme: _transition()),
          darkTheme: _themeDark().copyWith(pageTransitionsTheme: _transition()),
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
