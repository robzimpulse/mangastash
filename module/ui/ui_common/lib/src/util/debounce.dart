import 'dart:async';

/// Runs its callback only after [delay] of call-silence: every [call]
/// resets the timer, so a burst of invocations triggers the callback once,
/// with the last value. Cancel a pending callback with [cancel] (e.g. when
/// a newer, immediate action supersedes it); release the timer entirely
/// with [dispose].
class Debounce {
  Debounce({this.delay = const Duration(milliseconds: 300)});

  final Duration delay;
  Timer? _timer;

  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Drops the pending callback, if any. The instance stays usable — a
  /// later [call] re-arms the timer as usual.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}
