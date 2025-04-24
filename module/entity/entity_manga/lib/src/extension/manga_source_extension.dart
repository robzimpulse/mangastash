import 'package:manga_service_firebase/manga_service_firebase.dart';

import '../../entity_manga.dart';

extension MangaSourceExtension on MangaSourceFirebase {
  MangaSourceEnum? get asEnum =>
      name?.isNotEmpty == true ? MangaSourceEnum.fromValue(name) : null;
}
