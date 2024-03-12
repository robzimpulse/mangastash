import 'dart:developer';

import 'package:service_locator/service_locator.dart';

import 'firebase_service/manga_service_firebase.dart';
import 'firebase_service/manga_source_service_firebase.dart';
import 'firebase_service/manga_tag_service_firebase.dart';

class DataMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: 'data_storage');

    locator.registerFactory(() => MangaSourceServiceFirebase(app: locator()));
    locator.registerFactory(() => MangaServiceFirebase(app: locator()));
    locator.registerFactory(() => MangaTagServiceFirebase(app: locator()));

    log('finish register', name: 'data_storage');
  }

}