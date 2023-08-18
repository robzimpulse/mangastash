import 'package:intl/intl.dart';

extension ReadableDateFormatExtension on DateTime {
  String get ddLLLLyy {
    return DateFormat('dd LLLL yyyy').format(this);
  }
}
