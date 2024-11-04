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

  DateTime _nextAvailable = DateTime.now();
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

    var now = DateTime.now();
    _mutex.protect(() async {
      if (now.isBefore(_nextAvailable)) {
        // Throttle this request
        var scheduledTime = _nextAvailable;
        // Compute the next time a request is able to be fired
        _nextAvailable = _nextAvailable.add(interval);
        return scheduledTime;
      } else {
        // Not throttled, fire the request immediately
        _nextAvailable = now.add(interval);
        return null;
      }
    }).then((scheduledTime) {
      if (scheduledTime != null) {
        onThrottled?.call(options, scheduledTime);
        Future.delayed(
          scheduledTime.difference(now),
          () => handler.next(options),
        );
      } else {
        handler.next(options);
      }
    });
  }
}
