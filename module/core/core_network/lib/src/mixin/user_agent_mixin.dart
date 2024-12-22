mixin UserAgentMixin {
  final userAgent = UserAgentMixin.staticUserAgent;

  static String staticUserAgent = 'Mozilla/5.0 '
      '(Macintosh; Intel Mac OS X 10_15_7) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/127.0.0.0 '
      'Safari/537.36';
}