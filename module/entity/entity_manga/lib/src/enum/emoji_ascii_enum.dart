enum EmojiAsciiEnum {
  /// ¯\_(ツ)_/¯
  raiseShoulders('¯\\_(ツ)_/¯'),

  /// ⊙﹏⊙
  confused('⊙﹏⊙'),

  /// ･o･;
  sweat('･o･;'),

  /// Σ(ಠ_ಠ)
  surprised('Σ(ಠ_ಠ)'),

  /// ಥ_ಥ
  crying('ಥ_ಥ'),

  /// (˘･_･˘)
  shy('(˘･_･˘)'),

  /// (；￣Д￣)
  scared('(；￣Д￣)'),

  /// (･Д･。
  angry('(･Д･。');

  const EmojiAsciiEnum(this.ascii);

  final String ascii;

  @override
  String toString() => ascii;
}