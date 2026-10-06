import 'http_status_exception.dart';

class RateLimitException extends HttpStatusException {
  final Duration? retryAfter;

  RateLimitException({
    required super.cause,
    this.retryAfter,
    super.bodySnippet,
  }) : super(statusCode: 429);

  @override
  String toString() {
    final retry = retryAfter == null ? '' : ' retryAfter: ${retryAfter!.inSeconds}s';
    return '$runtimeType : 429$retry';
  }
}
