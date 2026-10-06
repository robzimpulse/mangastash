import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/src/model/chapter/chapter_response.dart';
import 'package:manga_dex_api/src/model/chapter/search_chapter_parameter.dart';
import 'package:manga_dex_api/src/model/chapter/search_chapter_response.dart';
import 'package:manga_dex_api/src/repository/chapter_repository.dart';
import 'package:manga_dex_api/src/service/chapter_service.dart';
import 'package:manga_dex_api/src/service/manga_service.dart';

class _MockMangaService implements MangaService {
  int? capturedEmptyPages;
  int? capturedFuturePublishAt;
  int? capturedExternalUrl;
  String? capturedFutureUpdates;

  @override
  Future<SearchChapterResponse> feed({
    String? id,
    int? limit,
    int? offset,
    List<String>? translatedLanguage,
    List<String>? originalLanguage,
    List<String>? excludedOriginalLanguage,
    List<String>? contentRating,
    List<String>? excludedGroups,
    List<String>? excludedUploaders,
    String? includeFutureUpdates,
    String? createdAtSince,
    String? updatedAtSince,
    String? publishedAtSince,
    List<String>? includes,
    int? includeEmptyPages,
    int? includeFuturePublishAt,
    int? includeExternalUrl,
    Map<String, String>? orders,
  }) async {
    capturedEmptyPages = includeEmptyPages;
    capturedFuturePublishAt = includeFuturePublishAt;
    capturedExternalUrl = includeExternalUrl;
    capturedFutureUpdates = includeFutureUpdates;
    return const SearchChapterResponse('ok', null, [], 0, 0, 0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockChapterService implements ChapterService {
  @override
  Future<ChapterResponse> detail({String? id, List<String>? includes}) async {
    throw UnimplementedError();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('feed sends none of the exclusive include* flags (default feed)', () async {
    final mockService = _MockMangaService();
    final chapterRepository = ChapterRepository(
      mangaService: mockService,
      chapterService: _MockChapterService(),
    );

    await chapterRepository.feed(
      mangaId: 'manga-id',
      parameter: const SearchChapterParameter(
        limit: 500,
        offset: 0,
      ),
    );

    // Live API semantics (verified 2026-10-06): each include* flag set to 1 is
    // an EXCLUSIVE filter ("only empty-page / only external / only future
    // chapters") — flag=1 zeroed the feed of every probed title (9 → 0,
    // 1044 → 0) and flag=2 is an API error. The default feed (no flags)
    // already matches the site's chapter list, so none of them may be sent.
    expect(mockService.capturedEmptyPages, isNull);
    expect(mockService.capturedFuturePublishAt, isNull);
    expect(mockService.capturedExternalUrl, isNull);
    expect(mockService.capturedFutureUpdates, isNull);
  });
}