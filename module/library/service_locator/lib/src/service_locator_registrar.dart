import 'service_locator.dart';

/// The class for a package to declare the services that it'll provide.
abstract class Registrar {
  /// this function will be called everytime the app starts up.
  Future<void> register(ServiceLocator locator);
}

/// The class for a library to declare the services that it'll provide.
///
/// This is basically an alias for Registrar, directed for library purposes
/// because libraries usually uses the 'init' terminology instead of register.
abstract class Initiator implements Registrar {
  /// this function will be called everytime the app starts up.
  @override
  Future<void> register(ServiceLocator locator) {
    return init(locator);
  }

  /// this function is basically an alias for register.
  Future<void> init(ServiceLocator locator);
}
