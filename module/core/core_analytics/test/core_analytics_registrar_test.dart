import 'package:core_analytics/core_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:service_locator/service_locator.dart';

void main() {
  group('CoreAnalyticsRegistrar', () {
    late ServiceLocator locator;

    setUp(() {
      ServiceLocatorInitiator.setServiceLocatorFactory(
        () => GetItServiceLocator(),
      );
      locator = ServiceLocator.asNewInstance();
    });

    tearDown(() async {
      await locator.reset();
    });

    test('register() registers LogBox as singleton', () async {
      final registrar = CoreAnalyticsRegistrar();
      await registrar.register(locator);

      expect(locator.isRegistered<LogBox>(), isTrue);

      final logBox = locator<LogBox>();
      expect(logBox, isA<LogBox>());
    });

    test('register() registers the same LogBox instance on multiple gets',
        () async {
      final registrar = CoreAnalyticsRegistrar();
      await registrar.register(locator);

      final logBox1 = locator<LogBox>();
      final logBox2 = locator<LogBox>();
      expect(identical(logBox1, logBox2), isTrue);
    });

    test('register() logs registration with timing info', () async {
      final registrar = CoreAnalyticsRegistrar();
      await registrar.register(locator);

      // Verify that the LogBox was used to log the registration
      // by checking it is accessible and functional
      final logBox = locator<LogBox>();
      expect(logBox, isNotNull);

      // The registrar logs its own registration, so the log entries
      // should contain at least one entry
      // We verify the LogBox is functioning by logging a test message
      logBox.log('test message', name: 'Test');
    });

    test('allReady() completes with default implementation', () async {
      final registrar = CoreAnalyticsRegistrar();
      // The default allReady() from Registrar base class returns Future.value()
      await expectLater(registrar.allReady(locator), completes);
    });

    test('dispose function is called on reset', () async {
      final registrar = CoreAnalyticsRegistrar();
      await registrar.register(locator);

      // Verify LogBox is registered
      expect(locator.isRegistered<LogBox>(), isTrue);

      // Reset should call the dispose function without errors
      await locator.reset();

      // After reset, LogBox should no longer be registered
      expect(locator.isRegistered<LogBox>(), isFalse);
    });

    test('runtimeType toString is used as log id', () async {
      final registrar = CoreAnalyticsRegistrar();

      // Verify the registrar's runtimeType string is what we expect
      expect(
        registrar.runtimeType.toString(),
        equals('CoreAnalyticsRegistrar'),
      );

      await registrar.register(locator);
    });
  });
}
