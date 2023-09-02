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
