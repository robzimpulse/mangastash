import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';

import '../../manager/headless_webview_manager.dart';

class SearchChapterOnMangaClashUseCase {
  final MangaServiceFirebase _mangaServiceFirebase;
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;
  final HeadlessWebviewManager _webview;

  SearchChapterOnMangaClashUseCase({
    required MangaServiceFirebase mangaServiceFirebase,
    required MangaChapterServiceFirebase mangaChapterServiceFirebase,
    required HeadlessWebviewManager webview,
  })  : _mangaServiceFirebase = mangaServiceFirebase,
        _mangaChapterServiceFirebase = mangaChapterServiceFirebase,
        _webview = webview;

  Future<Result<List<MangaChapter>>> execute({
    required String? mangaId,
    Language? language,
  }) async {
    if (mangaId == null) return Error(Exception('Manga ID Empty'));

    final result = await _mangaServiceFirebase.get(id: mangaId);
    final url = result?.webUrl;

    if (result == null || url == null) {
      return Error(Exception('Data not found'));
    }

    final document = await _webview.open(url);

    if (document == null) {
      return Error(Exception('Error parsing html'));
    }

    final List<MangaChapter> chapters = [];

    for (final element in document.querySelectorAll('li.wp-manga-chapter')) {
      final title = element.querySelector('a')?.text.split('-').lastOrNull;
      final text = element.querySelector('a')?.text.split(' ').map(
        (text) {
          final value = double.tryParse(text);

          if (value != null) {
            final fraction = value - value.truncate();
            if (fraction > 0.0) return value;
          }

          return int.tryParse(text);
        },
      );
      final releaseDate = element
          .querySelector('.chapter-release-date')
          ?.text
          .trim()
          .asDateTimeFromMMddyyyy
          ?.toIso8601String();
      final chapter = text?.whereNotNull().firstOrNull;

      chapters.add(
        MangaChapter(
          mangaId: mangaId,
          mangaTitle: result.title,
          title: title?.trim(),
          chapter: chapter != null ? '$chapter' : null,
          readableAt: releaseDate,
        ),
      );
    }

    return Success(await _mangaChapterServiceFirebase.sync(values: chapters));
  }
}
