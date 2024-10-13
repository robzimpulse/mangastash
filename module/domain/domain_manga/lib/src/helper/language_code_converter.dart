import 'package:core_environment/core_environment.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

extension LanguageToLanguageCode on Language {
  List<LanguageCodes> get languageCodes {
    switch (this) {
      case Language.zhHans:
        return [LanguageCodes.simplifiedChinese];
      case Language.zhHant:
        return [LanguageCodes.traditionalChinese];
      case Language.portuguese:
        return [LanguageCodes.brazillianPortugese];
      case Language.spanish:
        return [
          LanguageCodes.castilianSpanish,
          LanguageCodes.latinAmericaSpanish,
        ];
      case Language.japanese:
        return [LanguageCodes.romanizedJapanese];
      case Language.korean:
        return [LanguageCodes.romanizedKorean];
      default:
        return [LanguageCodes.english];
    }
  }
}
