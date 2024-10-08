import 'dart:ui';

import '../enum/country.dart';

extension CountryExt on Locale {
  Country? get country {
    final code = countryCode;
    if (code == null) return null;
    return Country.fromCode(code);
  }
}
