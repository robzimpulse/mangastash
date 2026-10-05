class AtHomeServerException implements Exception {
  AtHomeServerException();

  @override
  String toString() => '$runtimeType : at-home server response missing baseUrl';
}
