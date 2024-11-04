import 'dart:developer';

import 'package:service_locator/service_locator.dart';

import 'firebase_service/manga_chapter_service_firebase.dart';
import 'firebase_service/manga_library_service_firebase.dart';
import 'firebase_service/manga_service_firebase.dart';
import 'firebase_service/manga_source_service_firebase.dart';
import 'firebase_service/manga_tag_service_firebase.dart';

class DataMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    log('start register', name: runtimeType.toString(), time: DateTime.now());

    locator.registerFactory(() => MangaSourceServiceFirebase(app: locator()));

    locator.registerFactory(() => MangaServiceFirebase(app: locator()));

    locator.registerFactory(() => MangaTagServiceFirebase(app: locator()));

    locator.registerFactory(() => MangaChapterServiceFirebase(app: locator()));

    locator.registerFactory(() => MangaLibraryServiceFirebase(app: locator()));

    log('finish register', name: runtimeType.toString(), time: DateTime.now());
  }
}
