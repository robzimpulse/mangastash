// The "source moved" failure (issue #206): thrown by the gated use cases
// (GetMangaUseCase / SearchChapterUseCase / GetChapterUseCase) when a saved
// manga or chapter lives on a host its source no longer serves and nothing
// usable is stored. It is not a script fault and not transient — error UIs
// must offer neither "Fix source" nor "Retry" for it (`fixSourceTargetOf`
// returns null), because no edit or retry can bring the old host back.
//
// Usage:
//   throw SourceMovedException(sourceName: source.name, host: movedHost);
//   catch sites wrap it in an `Error` result like any other failure.
class SourceMovedException implements Exception {
  const SourceMovedException({required this.sourceName, required this.host});

  /// Display name of the source that moved.
  final String sourceName;

  /// The stored URL's host the source no longer serves.
  final String host;

  @override
  String toString() => 'Source moved: $sourceName no longer serves $host.';
}
