import 'package:log_box/log_box.dart';
import 'package:manga_service_firebase/manga_service_firebase.dart';
import 'package:service_locator/service_locator.dart';

import 'firebase_service/manga_chapter_service_firebase.dart';
import 'firebase_service/manga_library_service_firebase.dart';
import 'firebase_service/manga_service_firebase.dart';
import 'firebase_service/manga_source_service_firebase.dart';

class DataMangaRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final LogBox log = locator();
    log.log('start register', name: runtimeType.toString());

    void logger(
      message, {
      error,
      extra,
      level,
      name,
      sequenceNumber,
      stackTrace,
      time,
      zone,
    }) {
      return log.log(
        message,
        name: name ?? runtimeType.toString(),
        sequenceNumber: sequenceNumber,
        level: level ?? 0,
        zone: zone,
        error: error,
        stackTrace: stackTrace,
        time: time,
      );
    }

    locator.registerFactory(() => MangaSourceServiceFirebase(app: locator()));
    locator.registerFactory(
      () => MangaServiceFirebase(
        app: locator(),
        logBox: log,
      ),
    );
    locator.registerFactory(
      () => MangaTagServiceFirebase(
        app: locator(),
        logger: logger,
      ),
    );
    locator.registerFactory(
      () => MangaChapterServiceFirebase(
        app: locator(),
        logBox: log,
      ),
    );
    locator.registerFactory(() => MangaLibraryServiceFirebase(app: locator()));

    log.log('finish register', name: runtimeType.toString());
  }
}
