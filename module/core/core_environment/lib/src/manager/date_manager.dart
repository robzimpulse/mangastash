import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/listen_current_timezone_use_case.dart';

class DateManager implements ListenCurrentTimezoneUseCase {
  final BehaviorSubject<String> _currentTimeZoneData;

  late final StreamSubscription _subscription;

  DateManager({
    required String initialTimeZoneData,
    required AsyncValueGetter<String> fetcher,
  }) : _currentTimeZoneData = BehaviorSubject.seeded(initialTimeZoneData) {
    _subscription = Stream.periodic(
      const Duration(minutes: 5),
      (_) => fetcher(),
    ).asyncMap((e) async => await e).listen(_currentTimeZoneData.add);
  }

  static Future<DateManager> create({
    required AsyncValueGetter<String> fetcher,
  }) async {
    return DateManager(initialTimeZoneData: await fetcher(), fetcher: fetcher);
  }

  @override
  ValueStream<String> get timezoneDataStream => _currentTimeZoneData.stream;

  Future<void> dispose() => _subscription.cancel();
}
