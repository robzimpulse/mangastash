// fixSourceLocation: resolves a "Fix source" request (issue #115) to the source
// editor's route location, or null when the source cannot be edited.
//
// The failing source arrives by display name (that is all the error carries);
// the editor is keyed by script id, so the name is resolved through
// [scriptIdOf] (defaults to the live source registry via `Sources.fromName`).
// Only scripted sources have an id - MangaDex is a native built-in with no
// script, so it resolves to null and the caller does nothing.
//
// Usage:
//   final location = fixSourceLocation(target);
//   if (location != null) context.push(location);
import 'package:domain_manga/domain_manga.dart';
import 'package:feature_common/feature_common.dart';
import 'package:feature_more/feature_more.dart';

String? fixSourceLocation(
  FixSourceTarget target, {
  String? Function(String name) scriptIdOf = _registryScriptId,
}) {
  final id = scriptIdOf(target.sourceName);
  if (id == null) return null;

  final url = target.url;
  return Uri(
    path: MoreRoutePath.sourceEditor,
    queryParameters: {
      'id': id,
      'function': target.function,
      if (url != null) 'url': url,
    },
  ).toString();
}

/// Script id of the registry source called [name]; null for an unknown name
/// or a source without a script (MangaDex).
String? _registryScriptId(String name) {
  final source = Sources.fromName(name);
  return source is ScriptSourceExternal ? source.script.id : null;
}
