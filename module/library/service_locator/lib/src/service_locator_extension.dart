import 'package:lazy_evaluation/lazy_evaluation.dart';

import 'service_locator.dart';

/// Misc helpers
extension ServiceLocatorX on ServiceLocator {
  /// Registers a type alias, so whenever the first type [A] is requested,
  /// It redirects it to as type B
  void alias<A extends Object, B extends A>() {
    assert(
      A != Object && B != A,
      "The Generics must be specified, also A & B must be different",
    );
    final locator = this;
    locator.registerFactory<A>(
      () => locator<B>(),
    );
  }

  /// Provides the instance of a registered type [T] optionally.
  ///
  /// If the type is registered, it'll retrieves or creates an instance.
  /// Otherwise, return null.
  T? getOrNull<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    if (isRegistered<T>()) {
      return get<T>(
        instanceName: instanceName,
        param1: param1,
        param2: param2,
      );
    }
    return null;
  }

  /// Returns the instance of a registered type [T] wrapped in a Factory<T>.
  Factory<T> factory<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    final locator = this;
    return () => locator(
          instanceName: instanceName,
          param1: param1,
          param2: param2,
        );
  }

  /// Returns the instance of a registered type wrapped in a FactoryAsync<T>.
  FactoryAsync<T> factoryAsync<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    final locator = this;
    return () => locator.getAsync(
          instanceName: instanceName,
          param1: param1,
          param2: param2,
        );
  }

  /// Returns the instance of a registered type [T] wrapped in a Lazy<T>.
  Lazy<T> lazy<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    return Lazy(
      factory(
        instanceName: instanceName,
        param1: param1,
        param2: param2,
      ),
    );
  }

  /// Returns the instance of a registered type wrapped in a Lazy<Future<T>>.
  Lazy<Future<T>> lazyAsync<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    final locator = this;
    return Lazy(
      () => locator.getAsync(
        instanceName: instanceName,
        param1: param1,
        param2: param2,
      ),
    );
  }
}
