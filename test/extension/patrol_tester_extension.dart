import 'package:core_analytics/core_analytics.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:core_route/core_route.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:mangastash/screen/apps_screen.dart';
import 'package:mangastash/screen/error_screen.dart';
import 'package:mangastash/screen/splash_screen.dart';
import 'package:patrol_finders/patrol_finders.dart';
import 'package:service_locator/service_locator.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:universal_io/universal_io.dart';

import '../fake/fake_directory.dart';
import '../fake/fake_io_override.dart';
import '../fake/fake_method_channel.dart';
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
  List<String> availableTimezone = const ['Asia/Jakarta'],
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

    final binding = $.tester.binding.defaultBinaryMessenger;
    final methodChannel = FakeMethodChannel(
      onChannelsChanged: (channels) {
        for (final channel in channels.entries) {
          binding.setMockMethodCallHandler(channel.key, channel.value);
        }
      },
      onChannelTriggered: (channel, method) {
        return binding.handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(method),
          (_) {},
        );
      },
    );

    methodChannel.addChannel(
      channel: MethodChannel('flutter_timezone'),
      handler: (method) async {
        switch (method.method) {
          case 'getLocalTimezone':
            return timezone;
          case 'getAvailableTimezones':
            return availableTimezone;
        }

        throw Exception(
          'Unhandled [${method.method}] with argument [${method.arguments}]',
        );
      },
    );

    methodChannel.addChannel(
      channel: MethodChannel('plugins.flutter.io/path_provider'),
      handler: (method) async {
        switch (method.method) {
          case 'getApplicationDocumentsDirectory':
            return '/getApplicationDocumentsDirectory';
        }

        throw Exception(
          'Unhandled [${method.method}] with argument [${method.arguments}]',
        );
      },
    );

    /// set initial values for shared preferences
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    /// set initial values for shared preferences for legacy code
    /// ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});

    /// mock firebase related feature
    setupFirebaseCoreMocks();

    await IOOverrides.runWithIOOverrides(() async {
      await $.tester.runAsync(() async {
        locator.registerSingleton(methodChannel);

        // TODO: register module registrar here
        await locator.registerRegistrar(CoreAnalyticsRegistrar());
        await locator.registerRegistrar(CoreStorageRegistrar());
        await locator.registerRegistrar(CoreNetworkRegistrar());
        await locator.registerRegistrar(CoreEnvironmentRegistrar());
        await locator.registerRegistrar(CoreRouteRegistrar());
        await locator.registerRegistrar(DomainMangaRegistrar());

        locator.registerSingleton<Executor>(MemoryExecutor());
        locator.registerSingleton<ImagesCacheManager>(MockImagesCacheManager());
        locator.registerSingleton<ConverterCacheManager>(
          MockConverterCacheManager(),
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
      });

      await $.pumpWidget(
        WrapperScreen(
          locatorBuilder: () => Future.value(locator),
          appScreenBuilder: (_, locator) {
            return AppsScreen(locator: locator, setupError: (logbox) {});
          },
          splashScreenBuilder: (_) {
            return const SplashScreen();
          },
          errorScreenBuilder: (_, error) {
            return ErrorScreen(text: error.toString());
          },
        ),
      );
      await $.pumpAndTrySettle();
      await onRunTest.call(locator, $);
      await $.pumpAndTrySettle();
    }, FakeIOOverride(directory: FakeDirectory()));
    await $.tester.runAsync(() => locator.reset());
    debugDefaultTargetPlatformOverride = null;
  });
}
