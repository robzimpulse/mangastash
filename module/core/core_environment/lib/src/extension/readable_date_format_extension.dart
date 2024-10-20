import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

extension ReadableDateFormatExtension on DateTime {
  String get ddLLLLyy {
    return DateFormat('dd LLLL yyyy').format(this);
  }

  String get readableFormat {
    return timeago.format(this);
  }
}
