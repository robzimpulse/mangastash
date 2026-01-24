import 'package:entity_manga/entity_manga.dart';

abstract class ListenUnreadHistoryUseCase {
  Stream<List<MangaChapter>> get unreadHistoryStream;
}
