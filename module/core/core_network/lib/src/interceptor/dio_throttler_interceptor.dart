import 'package:dio/dio.dart';
import 'package:mutex/mutex.dart';

/// A simple request throttler (rate limiter) for Dio.
class DioThrottlerInterceptor extends Interceptor {
  /// The interval between which requests are fired.
  final Duration interval;

  /// A predicate to check whether a certain request should be throttled.
  ///
  /// If null, every request is throttled by default.
  bool Function(RequestOptions req)? shouldThrottle;

  /// Called when a request has been delayed execution. Useful for debugging.
  ///
  /// The second argument represents the time that the request is scheduled
  /// to be fired.
  void Function(RequestOptions req, DateTime until)? onThrottled;

  DateTime _next = DateTime.now();
  final Mutex _mutex = Mutex();

  DioThrottlerInterceptor(
    this.interval, {
    this.shouldThrottle,
    this.onThrottled,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (shouldThrottle?.call(options) == false) {
      handler.next(options);
      return;
    }

    // mark a timestamp
    final now = DateTime.now();

    // handle calculation scheduled time with mutex to eliminate race condition
    // when calculating value [_next].
    _mutex
        .protect(() => _calculateNextScheduledTime(now))
        .then((date) => _handleNextScheduledTime(options, handler, now, date));
  }

  Future<DateTime?> _calculateNextScheduledTime(DateTime now) async {
    // calculate the next scheduled time based on future scheduled time
    if (now.isBefore(_next)) {
      final scheduledTime = _next;
      // Compute the next scheduled time for a request
      _next = _next.add(interval);
      return scheduledTime;
    }

    // compute next scheduled time for a request
    _next = now.add(interval);
    return null;
  }

  void _handleNextScheduledTime(
    RequestOptions options,
    RequestInterceptorHandler handler,
    DateTime now,
    DateTime? scheduledTime,
  ) {
    if (scheduledTime == null) {
      // Not throttled, fire the request immediately
      handler.next(options);
      return;
    }

    // Throttled, fire the request on the scheduled date
    onThrottled?.call(options, scheduledTime);
    Future.delayed(scheduledTime.difference(now), () => handler.next(options));
  }
}
