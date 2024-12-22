import 'package:collection/collection.dart';

mixin GenerateTaskIdMixin {
  String generateTaskId({
    String? url,
    String? directory,
    String? filename,
    String? group,
  }) {
    return [url, directory, filename, group]
        .whereNotNull()
        .join('')
        .hashCode
        .toString();
  }
}