import 'dart:ui';

import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:mangastash/screen/apps_screen.dart';
import 'package:mangastash/screen/error_screen.dart';
import 'package:mangastash/screen/splash_screen.dart';
import 'package:mangastash/screen/wrapper_screen.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:service_locator/service_locator.dart';

import '../mock/mock_get_timezone_use_case.dart';
import '../mock/mock_shared_preferences_async.dart';
import '../mock/mock_storage_manager.dart';

typedef OnRunTest = Future<void> Function(ServiceLocator l, PatrolTester $);

typedef OnSetupTest = Future<void> Function(ServiceLocator l);

void testScreen(
  String description, {
  OnSetupTest? onSetupTest,
  required OnRunTest onRunTest,
  double width = 400,
  double height = 800,
  double dpi = 2.625,
  double textScaleFactor = 1.1,
  String timezone = 'Asia/Jakarta',
}) {
  ServiceLocatorInitiator.setServiceLocatorFactory(
    () => GetItServiceLocator()..setAllowReassignment(true),
  );

  patrolWidgetTest(description, ($) async {
    $.tester.view.physicalSize = Size(width * dpi, height * dpi);
    await $.tester.binding.setSurfaceSize(Size(width * dpi, height * dpi));
    $.tester.view.devicePixelRatio = dpi;
    $.tester.platformDispatcher.textScaleFactorTestValue = textScaleFactor;

    TestWidgetsFlutterBinding.ensureInitialized();
    final locator = ServiceLocator.asNewInstance();
    await $.pumpWidget(
      WrapperScreen(
        locatorBuilder: () {
          return Future(() async {
            // TODO: register module registrar here
            await locator.registerRegistrar(CoreAnalyticsRegistrar());
            await locator.registerRegistrar(CoreStorageRegistrar());
            await locator.registerRegistrar(CoreNetworkRegistrar());
            await locator.registerRegistrar(CoreEnvironmentRegistrar());
            await locator.registerRegistrar(CoreRouteRegistrar());
            await locator.registerRegistrar(DomainMangaRegistrar());

            locator.registerSingleton<GetTimeZoneUseCase>(
              MockGetTimezoneUseCase()..setLocal(timezone: timezone),
            );
            locator.registerSingleton<SharedPreferencesAsync>(
              MockSharedPreferencesAsync(),
            );
            locator.registerSingleton<Executor>(MemoryExecutor());
            locator.registerSingleton<ImageCacheManager>(
              MockImageCacheManager(),
            );
            locator.registerSingleton<ConverterCacheManager>(
              MockConverterCacheManager(),
            );
            locator.registerSingleton<TagCacheManager>(MockTagCacheManager());
            locator.registerSingleton<MangaCacheManager>(
              MockMangaCacheManager(),
            );
            locator.registerSingleton<ChapterCacheManager>(
              MockChapterCacheManager(),
            );
            locator.registerSingleton<HtmlCacheManager>(MockHtmlCacheManager());
            locator.registerSingleton<SearchChapterCacheManager>(
              MockSearchChapterCacheManager(),
            );
            locator.registerSingleton<SearchMangaCacheManager>(
              MockSearchMangaCacheManager(),
            );

            await onSetupTest?.call(locator);

            await locator.allReady();

            return locator;
          });
        },
        appScreenBuilder: (_, locator) {
          return AppsScreen(locator: locator, setupError: (logbox) {});
        },
        splashScreenBuilder: (_) => const SplashScreen(),
        errorScreenBuilder: (_, error) => ErrorScreen(text: error.toString()),
      ),
    );

    await $.pumpAndTrySettle();
    await onRunTest.call(locator, $);
    await $.tester.runAsync(() => locator.reset());
    await $.pumpAndTrySettle();
    debugDefaultTargetPlatformOverride = null;
  });
}
