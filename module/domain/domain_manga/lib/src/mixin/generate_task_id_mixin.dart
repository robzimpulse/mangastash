mixin GenerateTaskIdMixin {
  String generateTaskId({
    String? url,
    String? directory,
    String? filename,
  }) {
    return [url, directory, filename]
        .nonNulls
        .join('')
        .hashCode
        .toString();
  }
}