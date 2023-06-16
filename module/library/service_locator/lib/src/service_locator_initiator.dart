import 'service_locator.dart';

/// The identifying error for service locator factory not yet set.
class ServiceLocatorFactoryNotSetError extends Error {}

/// The initiator that must be called during the app startup.
class ServiceLocatorInitiator {
  /// Set the Service Locator factory implementation.
  static void setServiceLocatorFactory(ServiceLocator Function() generator) {
    _generator = generator;
  }

  /// Create a new Service Locator instance from the generator.
  static ServiceLocator newServiceLocator() {
    final generator = _generator;
    if (generator == null) {
      throw ServiceLocatorFactoryNotSetError();
    }
    return generator();
  }

  static ServiceLocator Function()? _generator;
}
