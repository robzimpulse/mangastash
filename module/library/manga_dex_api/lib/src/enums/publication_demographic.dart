enum PublicDemographic {
  shounen('shounen'),
  shoujo('shoujo'),
  josei('josei'),
  seinen('seinen'),
  none('none');

  final String rawValue;

  const PublicDemographic(this.rawValue);
}
