import 'package:entity_manga/entity_manga.dart';

abstract class ListenReadHistoryUseCase {
  Stream<List<MangaChapter>> get readHistoryStream;
}
