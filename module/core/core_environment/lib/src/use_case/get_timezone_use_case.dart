import 'package:flutter_timezone/flutter_timezone.dart';

class GetTimeZoneUseCase {
  Future<String> local() => FlutterTimezone.getLocalTimezone();

  Future<List<String>> available() => FlutterTimezone.getAvailableTimezones();
}