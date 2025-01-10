import 'package:intl/intl.dart';

extension ParseableDateStringExtension on String {
  DateTime? get asDateTimeFromISO8601 {
    try {
      return DateFormat('yyyy-MM-ddTHH:mm:ss.mmmZ').parse(this).toUtc();
    } on Exception {
      return null;
    }
  }
  DateTime? get asDateTimeFromMMddyyyy {
    try {
      return DateFormat('MM/dd/yyyy').parse(this).toUtc();
    } on Exception {
      return null;
    }
  }
}
