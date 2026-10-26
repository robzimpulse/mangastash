/// Contract for running one function of a MangaStash JS source script, plus
/// the result type and the cache key of its JSON result cache.
///
/// Purpose: [RunSourceScriptUseCase] is how the domain layer executes source
/// scripts (spec §6 Runtime) without knowing about webviews. Page functions
/// (`search`, `manga`, `chapters`, `images`, `tags`) run inside the loaded
/// site via [RunSourceScriptUseCase.runOnPage]; URL builders (`searchUrl`,
/// `chaptersUrl`, `tagsUrl`) run in a warm, reused blank webview via
/// [RunSourceScriptUseCase.runOnBlank]. Validated page results are cached as
/// JSON for 30 minutes under [sourceScriptCacheKey], so editing a script
/// (its code is hashed into the key) naturally invalidates its cache.
/// Usage: resolve `locator<RunSourceScriptUseCase>()` (registered as an alias
/// of `HeadlessWebviewManager` by `CoreNetworkRegistrar`), then e.g.
/// `await useCase.runOnPage(url: u, code: js, function: 'search',
/// baseUrl: b, searchTerm: t)` and read [ScriptRunResult.value]. Script
/// failures and timeouts throw `SourceScriptException`. Call
/// [RunSourceScriptUseCase.evict] to drop every cached result for a URL.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Outcome of [RunSourceScriptUseCase.runOnPage].
class ScriptRunResult {
  const ScriptRunResult({
    required this.value,
    required this.elapsed,
    this.html,
    this.fromCache = false,
  });

  /// The function's return value, decoded from JSON (maps, lists, scalars).
  final Object? value;

  /// The raw, untrimmed page HTML after the run; only set when the caller
  /// asked for `captureHtml`.
  final String? html;

  /// Wall time of the whole call, cache read included.
  final Duration elapsed;

  /// Whether [value] came from the JSON result cache (no webview was built).
  final bool fromCache;
}

/// Cache key of a page function's JSON result: the page [url], the called
/// [function] and a SHA-1 over the script [code] and [searchTerm] (separated
/// by a NUL byte so `code + term` boundaries cannot collide). Shape:
/// `script|<url>|<function>|<sha1>`; [RunSourceScriptUseCase.evict] relies on
/// the `script|<url>|` prefix.
String sourceScriptCacheKey({
  required String url,
  required String function,
  required String code,
  String? searchTerm,
}) {
  final digest = sha1.convert([
    ...utf8.encode(code),
    0,
    ...utf8.encode(searchTerm ?? ''),
  ]);
  return 'script|$url|$function|$digest';
}

/// Stable SHA-1 hex digest of a script's [code]: its identity for caches that
/// outlive one run (a persisted result keyed with it stops matching as soon as
/// the script is edited, see `SearchMangaUseCase` in domain_manga).
String sourceScriptCodeHash(String code) {
  return sha1.convert(utf8.encode(code)).toString();
}

abstract class RunSourceScriptUseCase {
  /// Loads [url] in a fresh headless webview (same UA, Cloudflare retry and
  /// diagnostics plumbing as page fetches), runs `source[function](document,
  /// ctx)` and returns its JSON result. [timeout] (default 15 s) bounds the
  /// script call. [useCache] reads/writes the 30-minute JSON result cache;
  /// [captureHtml] attaches the page HTML to the result or exception and
  /// always bypasses the cache.
  Future<ScriptRunResult> runOnPage({
    required String url,
    required String code,
    required String function,
    required String baseUrl,
    String? searchTerm,
    Duration? timeout,
    bool useCache = true,
    bool captureHtml = false,
  });

  /// Runs `source[function](...args, ctx)` in the shared warm blank webview
  /// and returns its JSON-decoded result. Calls are serialized; [timeout]
  /// (default 15 s) bounds each call.
  Future<Object?> runOnBlank({
    required String code,
    required String function,
    required String baseUrl,
    List<Object?> args = const [],
    Duration? timeout,
  });

  /// Removes every cached script result for [url] (all functions/scripts).
  Future<void> evict({required String url});
}
