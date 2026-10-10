// Domain validators for scraped results (issue #114): use cases run them
// between the source call and the DB sync/cache write, failing with a
// FailedParsingHtmlException that names the source, the script function that
// produced the data (`parser`: 'search', 'manga', 'chapters' or 'images' —
// issue #115) and the missing fields.
//
// Usage: `cards.requireCardFields(source: s.name, url: url, logBox: log)`,
// `detail.requireDetailFields(...)`, `rows.requireChapterFields(...)`,
// `requireChapterImages(images, source: s.name, url: url)`; wrap them in
// `validateOrEvict(runner, url: url, validate: ...)` so a failure also drops
// the runner's cached script result.
import 'package:core_analytics/core_analytics.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

/// Whether [value] carries actual content (non-null, non-blank).
bool _filled(String? value) => value?.trim().isNotEmpty ?? false;

extension MangaScrappedDetailValidation on MangaScrapped {
  /// Fails fast when a series-detail scrape came back without the fields
  /// every downstream flow needs (issue #114): a drifted detail selector
  /// used to return a null-title [MangaScrapped] that synced into the DB
  /// and only surfaced as a DataNotFoundException much later.
  ///
  /// Throws [FailedParsingHtmlException] with [source]/[url] context when
  /// [MangaScrapped.title] is missing.
  MangaScrapped requireDetailFields({
    required String source,
    required String url,
  }) {
    if (!_filled(title)) {
      throw FailedParsingHtmlException(
        url,
        source: source,
        parser: 'manga',
        missingFields: const ['title'],
      );
    }
    return this;
  }
}

extension MangaScrappedCardsValidation on List<MangaScrapped> {
  /// Keeps only search/browse cards with a usable [MangaScrapped.title]
  /// and [MangaScrapped.webUrl]; dropped cards are logged via [logBox].
  ///
  /// An empty list is a genuine "no results" and passes through. A
  /// non-empty list where every card lacks required fields is a broken
  /// extraction and throws [FailedParsingHtmlException] — rendering
  /// "no results" for a page full of cards would hide the breakage.
  List<MangaScrapped> requireCardFields({
    required String source,
    required String url,
    LogBox? logBox,
  }) {
    final valid =
        where((card) => _filled(card.title) && _filled(card.webUrl)).toList();

    if (isEmpty) return valid;
    if (valid.isEmpty) {
      throw FailedParsingHtmlException(
        url,
        source: source,
        parser: 'search',
        missingFields: const ['title', 'webUrl'],
      );
    }
    if (valid.length != length) {
      logBox?.log(
        'Dropped ${length - valid.length} cards missing required fields',
        extra: {'source': source, 'url': url},
        name: 'ScrappedValidation',
      );
    }
    return valid;
  }
}

extension ChapterScrappedRowsValidation on List<ChapterScrapped> {
  /// Keeps only chapter rows with a usable [ChapterScrapped.webUrl] (what
  /// the reader opens); dropped rows are logged via [logBox].
  ///
  /// An empty (or all-invalid) list throws [FailedParsingHtmlException]:
  /// a correctly parsed series page always carries chapter rows, so zero
  /// rows means the row anchors drifted — the silent reader breakage in
  /// issue #114.
  List<ChapterScrapped> requireChapterFields({
    required String source,
    required String url,
    LogBox? logBox,
  }) {
    if (isNotEmpty) {
      final valid = where((row) => _filled(row.webUrl)).toList();
      if (valid.isEmpty) {
        throw FailedParsingHtmlException(
          url,
          source: source,
          parser: 'chapters',
          missingFields: const ['chapter rows'],
        );
      }
      if (valid.length != length) {
        logBox?.log(
          'Dropped ${length - valid.length} chapter rows missing webUrl',
          extra: {'source': source, 'url': url},
          name: 'ScrappedValidation',
        );
      }
      return valid;
    }
    throw FailedParsingHtmlException(
      url,
      source: source,
      parser: 'chapters',
      missingFields: const ['chapter rows'],
    );
  }
}

/// Fails fast when a chapter reader scrape extracted no image URLs
/// (issue #114): an empty list used to sync as a "filled" chapter whose
/// reader then rendered nothing.
List<String> requireChapterImages(
  List<String> images, {
  required String source,
  required String url,
}) {
  if (images.isEmpty) {
    throw FailedParsingHtmlException(
      url,
      source: source,
      parser: 'images',
      missingFields: const ['image urls'],
    );
  }
  return images;
}

/// Runs [validate] on a scripted source's result fetched from [url]; when it
/// throws [FailedParsingHtmlException], first evicts [runner]'s cached results
/// for [url] (issue #115). The runner caches a script's JSON before domain
/// validation sees it, so without the eviction a broken result would be
/// served again for the cache's 30 minutes.
Future<T> validateOrEvict<T>(
  RunSourceScriptUseCase runner, {
  required String url,
  required T Function() validate,
}) async {
  try {
    return validate();
  } on FailedParsingHtmlException {
    await runner.evict(url: url);
    rethrow;
  }
}
