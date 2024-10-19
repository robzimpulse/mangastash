enum BooleanToIntEnum {
  trueValue(1),
  falseValue(0);

  final int rawValue;

  const BooleanToIntEnum(this.rawValue);

  factory BooleanToIntEnum.fromRawValue(int rawValue) {
    return BooleanToIntEnum.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => BooleanToIntEnum.falseValue,
    );
  }
}
