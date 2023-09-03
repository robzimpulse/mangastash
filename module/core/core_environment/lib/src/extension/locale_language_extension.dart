import 'dart:ui';

import '../enum/language.dart';

extension LanguageExt on Locale {
  Language get language => Language.fromCode(languageCode);
}
