import 'dart:async';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';

import '../adapter/timezone_adapter.dart'
    if (dart.library.io) '../adapter/timezone_adapter_mobile.dart'
    if (dart.library.js) '../adapter/timezone_adapter_web.dart';
import '../use_case/listen_current_timezone_use_case.dart';

class DateManager implements ListenCurrentTimezoneUseCase {
  final _currentTimeZoneData = BehaviorSubject<String>();

  DateManager() {
    _update(Timer.periodic(const Duration(minutes: 5), _update));
  }

  static Future<DateManager> init() async {
    await initializeTimeZone();
    return DateManager();
  }

  @override
  ValueStream<String> get timezoneDataStream => _currentTimeZoneData.stream;

  void _update(Timer t) async {
    final String tz = await FlutterNativeTimezone.getLocalTimezone();
    _currentTimeZoneData.add(tz);
  }
}
