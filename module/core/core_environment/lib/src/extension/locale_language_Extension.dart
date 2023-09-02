import 'dart:ui';

import 'package:collection/collection.dart';

import '../entity/language.dart';

extension LanguageExt on Locale {
  Language? language(List<Language> languages) {
    return languages.firstWhereOrNull(
      (element) => element.isoCode == languageCode,
    );
  }
}
