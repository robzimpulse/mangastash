class SourceMetadata {
  final String id;
  final String name;
  final String version;
  final String minAppVersion;
  final String baseUrl;
  final String iconUrl;

  const SourceMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.minAppVersion,
    required this.baseUrl,
    required this.iconUrl,
  });

  factory SourceMetadata.fromMap(Map<String, dynamic> map) {
    return SourceMetadata(
      id: map['id'] as String,
      name: map['name'] as String,
      version: map['version'] as String,
      minAppVersion: map['minAppVersion'] as String,
      baseUrl: map['baseUrl'] as String,
      iconUrl: map['iconUrl'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'minAppVersion': minAppVersion,
      'baseUrl': baseUrl,
      'iconUrl': iconUrl,
    };
  }
}
