import 'dart:developer';

import 'package:service_locator/service_locator.dart';

import '../data_manga.dart';
import 'firebase_service/source_service_firebase.dart';

class DataMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: 'data_storage');
    locator.registerFactory(() => SourceServiceFirebase(app: locator()));
    locator.alias<SourceService, SourceServiceFirebase>();
    log('finish register', name: 'data_storage');
  }

}