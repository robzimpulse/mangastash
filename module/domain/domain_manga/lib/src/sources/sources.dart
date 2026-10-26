// Static, read-only facade over the app's SourceRegistry (issue #115), for
// pure widgets and extensions that have no service-locator access (source
// icons in tiles, `Uri.source`). Domain code injects SourceRegistry instead.
//
// Usage:
//   Sources.bind(registry);        // DomainMangaRegistrar, once created
//   Sources.fromName('Asura Scans')?.iconUrl
//   Sources.fromHost(uri.host)
//   Sources.unbind(registry);      // when that registry is disposed
// Before a registry is bound (or after it is unbound) only the built-in
// MangaDex source resolves.
import 'package:collection/collection.dart';
import 'package:entity_manga_external/entity_manga_external.dart';

import '../manager/source_registry.dart';
import 'manga_dex_source_external.dart';

class Sources {
  static SourceRegistry? _registry;
  static final List<SourceExternal> _fallback = [MangaDexSourceExternal()];

  /// Makes [registry] the one every lookup reads from.
  static void bind(SourceRegistry registry) => _registry = registry;

  /// Forgets [registry] if it is the bound one (a newer binding is kept).
  static void unbind(SourceRegistry registry) {
    if (identical(_registry, registry)) _registry = null;
  }

  /// Current sources: MangaDex followed by the scripted ones.
  static List<SourceExternal> get values => _registry?.values ?? _fallback;

  static SourceExternal? fromName(String name) {
    return values.firstWhereOrNull((e) => e.name == name);
  }

  static SourceExternal? fromHost(String host) {
    return values.firstWhereOrNull(
      (e) => Uri.tryParse(e.baseUrl)?.host == host,
    );
  }
}
