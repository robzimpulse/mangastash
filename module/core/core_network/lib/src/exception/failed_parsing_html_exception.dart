class FailedParsingHtmlException implements Exception {

  final String url;

  FailedParsingHtmlException(this.url);

  @override
  String toString() => '$runtimeType : Failed parsing html from $url';

}