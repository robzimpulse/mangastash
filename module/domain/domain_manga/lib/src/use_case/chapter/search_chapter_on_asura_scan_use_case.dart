import 'package:core_environment/core_environment.dart';
import 'package:core_network/core_network.dart';
import 'package:data_manga/data_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:html/dom.dart';

import '../../manager/headless_webview_manager.dart';

class SearchChapterOnAsuraScanUseCase {
  final MangaServiceFirebase _mangaServiceFirebase;
  final MangaChapterServiceFirebase _mangaChapterServiceFirebase;
  final HeadlessWebviewManager _webview;

  SearchChapterOnAsuraScanUseCase({
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

    final container = document.querySelector(
      [
        'div',
        'pl-4',
        'pr-2',
        'pb-4',
        'overflow-y-auto',
        'scrollbar-thumb-themecolor',
        'scrollbar-track-transparent',
        'scrollbar-thin',
        'mr-3',
      ].join('.'),
    );

    for (final element in container?.children ?? <Element>[]) {
      final url = element.querySelector('a')?.attributes['href'];
      final titles = element
          .querySelector('h3.text-sm.text-white.font-medium.flex.flex-row')
          ?.text
          .split(' ')
          .map((e) => e.trim());
      final chapter = titles?.map((text) {
        final value = double.tryParse(text);

        if (value != null) {
          final fraction = value - value.truncate();
          if (fraction > 0.0) return value;
        }

        return int.tryParse(text);
      }).lastOrNull;
      final releaseDate = element
          .querySelector('h3.text-xs')
          ?.text
          .trim()
          .replaceAll('st', '')
          .replaceAll('nd', '')
          .replaceAll('rd', '')
          .replaceAll('th', '')
          .asDateTime
          ?.toIso8601String();

      chapters.add(
        MangaChapter(
          mangaId: mangaId,
          mangaTitle: result.title,
          chapter: chapter != null ? '$chapter' : null,
          readableAt: releaseDate,
          webUrl: ['https://asuracomic.net', 'series', url].join('/'),
        ),
      );
    }

    return Success(await _mangaChapterServiceFirebase.sync(values: chapters));
  }
}
