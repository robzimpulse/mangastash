enum BooleanToStringEnum {
  trueValue('1'),
  falseValue('0');

  final String rawValue;

  const BooleanToStringEnum(this.rawValue);

  factory BooleanToStringEnum.fromRawValue(String rawValue) {
    return BooleanToStringEnum.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => BooleanToStringEnum.falseValue,
    );
  }
}
