import 'package:change_case/change_case.dart';

extension DisplayableEnumExtension on Enum {
  String get label => name.toSentenceCase().toTitleCase();
}