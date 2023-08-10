import 'package:intl/intl.dart';

extension ParseableDateStringExtension on String {
  DateTime? get asDateTime {
    try {
      return DateFormat('yyyy-MM-DDThh:mm:ssZ').parse(this);
    } on Exception catch(e) {
      print(e.toString());
      return null;
    }
  }
}

