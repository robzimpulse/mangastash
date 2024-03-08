import 'package:service_locator/service_locator.dart';

import '../data_manga.dart';

class DataMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    locator.registerFactory(() => SourceService(app: locator()));
  }

}