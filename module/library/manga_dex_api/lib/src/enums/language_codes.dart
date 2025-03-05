enum LanguageCodes {
  english('en'),
  simplifiedChinese('zh'),
  traditionalChinese('zh-hk'),
  brazillianPortugese('pt-br'),
  castilianSpanish('es'),
  latinAmericaSpanish('es-la'),
  romanizedJapanese('ja-ro'),
  romanizedKorean('ko-ro'),
  romanizedChinese('zh-ro');

  final String rawValue;

  const LanguageCodes(this.rawValue);

  factory LanguageCodes.fromRawValue(String rawValue) {
    return LanguageCodes.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => LanguageCodes.english,
    );
  }
}
