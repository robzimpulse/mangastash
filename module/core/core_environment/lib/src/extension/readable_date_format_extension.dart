import 'package:timeago/timeago.dart' as timeago;

extension ReadableDateFormatExtension on DateTime {
  String get readableFormat {
    return timeago.format(this, allowFromNow: true);
  }
}
