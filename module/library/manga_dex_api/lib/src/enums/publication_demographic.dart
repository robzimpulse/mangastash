enum PublicDemographic {
  shounen('shounen'),
  shoujo('shoujo'),
  josei('josei'),
  seinen('seinen'),
  none('none');

  final String rawValue;

  const PublicDemographic(this.rawValue);

  factory PublicDemographic.fromRawValue(String rawValue) {
    return PublicDemographic.values.firstWhere(
      (e) => e.rawValue == rawValue,
      orElse: () => PublicDemographic.none,
    );
  }
}
