import 'package:service_locator/service_locator.dart';
import 'source_runtime.dart';

class CoreRuntimeRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    locator.registerLazySingleton(() => SourceRuntime());
  }
}
