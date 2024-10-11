import 'package:timezone/browser.dart' as tz;

Future<void> initializeTimeZone() async {
  await tz.initializeTimeZone(
    'assets/packages/timezone/data/latest.tzf',
  );
}
