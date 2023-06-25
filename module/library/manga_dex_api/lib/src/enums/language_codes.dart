enum LanguageCodes {
  english('en'),
  simplifiedChinese('zh'),
  traditionalChinese('zh_hk'),
  brazillianPortugese('pt_br'),
  castilianSpanish('es'),
  latinAmericaSpanish('es_la'),
  romanizedJapanese('ja_ro'),
  romanizedKorean('ko_ro'),
  romanizedChinese('zh_ro');

  final String rawValue;

  const LanguageCodes(this.rawValue);
}
