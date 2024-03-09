import 'dart:developer';

import 'package:service_locator/service_locator.dart';

import '../data_manga.dart';
import 'firebase_service/manga_service_firebase.dart';
import 'firebase_service/manga_tag_service_firebase.dart';
import 'firebase_service/source_service_firebase.dart';
import 'service/manga_service.dart';
import 'service/manga_tag_service.dart';

class DataMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: 'data_storage');

    locator.registerFactory(() => SourceServiceFirebase(app: locator()));
    locator.alias<SourceService, SourceServiceFirebase>();

    locator.registerFactory(() => MangaServiceFirebase(app: locator()));
    locator.alias<MangaService, MangaServiceFirebase>();

    locator.registerFactory(() => MangaTagServiceFirebase(app: locator()));
    locator.alias<MangaTagService, MangaTagServiceFirebase>();

    log('finish register', name: 'data_storage');
  }

}