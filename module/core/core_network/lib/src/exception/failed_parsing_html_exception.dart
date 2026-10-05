class FailedParsingHtmlException implements Exception {
  final String url;

  /// Name of the scraped source whose parser found nothing, when the
  /// failure comes from a source parse (issue #114) rather than the
  /// headless webview itself.
  final String? source;

  /// Which parser failed, e.g. `getManga`, `searchManga`, `listChapter`,
  /// `getChapterImage` — the SourceExternal hook the fields belong to.
  final String? parser;

  /// Required fields the scrape came back without, e.g. `title`,
  /// `webUrl`, `chapter rows` — human-readable, joined in [toString].
  final List<String> missingFields;

  FailedParsingHtmlException(
    this.url, {
    this.source,
    this.parser,
    this.missingFields = const [],
  });

  @override
  String toString() {
    final context = [
      if (source != null) 'source $source',
      if (parser != null) 'parser $parser',
      if (missingFields.isNotEmpty) 'missing ${missingFields.join(', ')}',
    ].join('; ');

    return context.isEmpty
        ? '$runtimeType : Failed parsing html from $url'
        : '$runtimeType : Failed parsing html from $url ($context)';
  }
}
