import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Highest source-script contract version this app understands.
/// A script whose header `contract` differs is not guaranteed to work.
const int kSupportedSourceContract = 1;

/// Thrown by [SourceScript.parse] when the script header is missing or invalid.
/// [message] is human readable and shown to the user in the script editor.
class SourceScriptFormatException implements Exception {
  final String message;

  const SourceScriptFormatException(this.message);

  @override
  String toString() => 'SourceScriptFormatException: $message';
}

/// A user-editable JavaScript source: its metadata header plus the full code.
///
/// Header grammar: optional BOM/whitespace, then a line
/// `// ==MangaStashSource==`, then lines each starting with `//` (the `//` and
/// one optional following space are stripped), then
/// `// ==/MangaStashSource==`. The joined inner text must be a JSON object:
///
/// ```js
/// // ==MangaStashSource==
/// // { "id": "my-source", "name": "My Source", "baseUrl": "https://x.com",
/// //   "version": 1, "contract": 1, "hosts": ["x.com"] }
/// // ==/MangaStashSource==
/// ```
///
/// Required keys: `id` (slug `^[a-z0-9]+(-[a-z0-9]+)*$`), `name`, `baseUrl`
/// (absolute http/https), `version` (int >= 1), `contract` (int >= 1), `hosts`
/// (non-empty list of bare host names). Optional: `iconUrl`, `timeouts`
/// (map of function name -> positive milliseconds; allowed names are in
/// [allowedTimeoutKeys]).
///
/// Use `SourceScript.parse(code)`; it throws [SourceScriptFormatException] on
/// any violation. [props] include [code], so editing the body changes equality.
class SourceScript extends Equatable {
  /// Default per-function timeout when the header does not override it.
  static const Duration defaultTimeout = Duration(milliseconds: 15000);

  /// Function names a header may set a timeout for.
  static const Set<String> allowedTimeoutKeys = {
    'searchUrl',
    'search',
    'manga',
    'chaptersUrl',
    'chapters',
    'images',
    'tagsUrl',
    'tags',
  };

  static const String _open = '// ==MangaStashSource==';
  static const String _close = '// ==/MangaStashSource==';
  static final RegExp _slug = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
  static final RegExp _host = RegExp(
    r'^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$',
  );

  final String id;
  final String name;
  final String baseUrl;
  final String iconUrl;
  final int version;
  final int contract;
  final List<String> hosts;

  /// Per-function timeout overrides in milliseconds.
  final Map<String, int> timeouts;

  /// The complete script text, header included.
  final String code;

  const SourceScript({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.iconUrl,
    required this.version,
    required this.contract,
    required this.hosts,
    required this.timeouts,
    required this.code,
  });

  /// Timeout for [function]: its override in [timeouts], else 15000 ms.
  Duration timeoutFor(String function) {
    final ms = timeouts[function];
    return ms == null ? defaultTimeout : Duration(milliseconds: ms);
  }

  /// Parses and validates the header of [code]; see the class docs.
  static SourceScript parse(String code) {
    final lines = code
        .replaceFirst(RegExp(r'^[﻿\s]+'), '')
        .split(RegExp(r'\r\n|\r|\n'));
    if (lines.first.trimRight() != _open) {
      throw const SourceScriptFormatException(
        'Script must start with "// ==MangaStashSource==" header',
      );
    }

    final inner = <String>[];
    var closed = false;
    for (final line in lines.skip(1)) {
      final trimmed = line.trimRight();
      if (trimmed == _close) {
        closed = true;
        break;
      }
      if (!trimmed.startsWith('//')) {
        throw const SourceScriptFormatException(
          'Every header line must start with "//"',
        );
      }
      final body = trimmed.substring(2);
      inner.add(body.startsWith(' ') ? body.substring(1) : body);
    }
    if (!closed) {
      throw const SourceScriptFormatException(
        'Header is missing the closing "// ==/MangaStashSource==" line',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(inner.join('\n'));
    } on FormatException catch (e) {
      throw SourceScriptFormatException(
        'Header is not valid JSON: ${e.message}',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const SourceScriptFormatException('Header JSON must be an object');
    }

    final id = _string(decoded, 'id');
    if (!_slug.hasMatch(id)) {
      throw SourceScriptFormatException(
        '"id" must be a lowercase slug like "my-source", got "$id"',
      );
    }
    final baseUrl = _string(decoded, 'baseUrl');
    final uri = Uri.tryParse(baseUrl);
    if (uri == null ||
        !uri.hasScheme ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      throw SourceScriptFormatException(
        '"baseUrl" must be an absolute http(s) URL, got "$baseUrl"',
      );
    }

    final iconUrl = decoded['iconUrl'];
    if (iconUrl != null && iconUrl is! String) {
      throw const SourceScriptFormatException('"iconUrl" must be a string');
    }

    return SourceScript(
      id: id,
      name: _string(decoded, 'name'),
      baseUrl: baseUrl,
      iconUrl: (iconUrl as String?) ?? '',
      version: _positiveInt(decoded, 'version'),
      contract: _positiveInt(decoded, 'contract'),
      hosts: _hosts(decoded),
      timeouts: _timeouts(decoded),
      code: code,
    );
  }

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
    throw SourceScriptFormatException(
      '"$key" is required and must be a string',
    );
  }

  static int _positiveInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int && value >= 1) return value;
    throw SourceScriptFormatException(
      '"$key" is required and must be an integer >= 1',
    );
  }

  static List<String> _hosts(Map<String, dynamic> json) {
    final value = json['hosts'];
    if (value is! List || value.isEmpty) {
      throw const SourceScriptFormatException(
        '"hosts" is required and must be a non-empty list',
      );
    }
    for (final host in value) {
      if (host is! String || !_host.hasMatch(host)) {
        throw SourceScriptFormatException(
          '"hosts" entries must be bare host names without scheme or path, '
          'got "$host"',
        );
      }
    }
    return List<String>.from(value);
  }

  static Map<String, int> _timeouts(Map<String, dynamic> json) {
    final value = json['timeouts'];
    if (value == null) return const {};
    if (value is! Map) {
      throw const SourceScriptFormatException('"timeouts" must be an object');
    }
    final result = <String, int>{};
    for (final entry in value.entries) {
      final key = entry.key;
      final ms = entry.value;
      if (!allowedTimeoutKeys.contains(key)) {
        throw SourceScriptFormatException(
          'Unknown timeout "$key"; allowed: ${allowedTimeoutKeys.join(', ')}',
        );
      }
      if (ms is! int || ms <= 0) {
        throw SourceScriptFormatException(
          'Timeout "$key" must be a positive integer (milliseconds)',
        );
      }
      result[key as String] = ms;
    }
    return result;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    baseUrl,
    iconUrl,
    version,
    contract,
    hosts,
    timeouts,
    code,
  ];
}
