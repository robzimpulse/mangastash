mixin GenerateTaskIdMixin {
  String generateTaskId({
    String? url,
    String? directory,
    String? filename,
    String? group,
  }) {
    return [url, directory, filename, group]
        .nonNulls
        .join('')
        .hashCode
        .toString();
  }
}