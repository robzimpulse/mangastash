import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:locale_emoji/locale_emoji.dart';

import '../entity/country.dart';
import '../entity/language.dart';

extension FlagEmojiLocaleExt on Locale {
  /// Get Flag Emoji from the Locale.
  String? get flagEmoji {
    return getFlagEmoji(
      languageCode: languageCode,
      scriptCode: scriptCode,
      countryCode: countryCode,
    );
  }
}

extension LanguageExt on Locale {
  Language? language(List<Language> languages) {
    return languages.firstWhereOrNull(
      (element) => element.isoCode == languageCode,
    );
  }
}

extension CountryExt on Locale {
  Country? country(List<Country> countries) {
    return countries.firstWhereOrNull(
      (element) => element.alpha2Code == countryCode,
    );
  }
}
