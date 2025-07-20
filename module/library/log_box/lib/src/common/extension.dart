import 'dart:convert';

import 'package:universal_io/io.dart';

import '../model/network_entry.dart';

extension NullableStringJsonExtension on String? {
  String get prettify {
    if (this != null) {
      try {
        var decoded = json.decode(this!);
        var encoder = const JsonEncoder.withIndent('  ');
        var prettyJson = encoder.convert(decoded);
        return prettyJson;
      } catch (e) {
        return 'N/A-Cannot Parse';
      }
    }
    return 'N/A';
  }

  bool get isJson {
    try {
      json.decode(this!);
      return true;
    } catch (_) {
      return false;
    }
  }

  String toJson() {
    return json.encode(this);
  }

  Map<String, dynamic> toMap() {
    if (this == null) {
      return <String, dynamic>{};
    }
    return json.decode(this!);
  }
}

extension MapJsonExtension on Map<String, dynamic> {
  String? get json {
    try {
      return jsonEncode(this);
    } catch (e) {
      return null;
    }
  }
}

extension DurationNetworkExtension on NetworkEntry {
  Duration get duration {
    final request = this.request;
    final response = this.response;
    if (request != null && response != null) {
      return response.time.difference(request.time);
    }
    return Duration.zero;
  }
}

extension CurlCommandExtension on NetworkEntry {
  String get curl {
    final String? body = request?.body?.toString();
    final encodingKey = HttpHeaders.acceptEncodingHeader.toLowerCase();
    final compressed = request?.headers?.entries.where(
      (entry) => [
        entry.key.toLowerCase() == encodingKey,
        entry.value == 'gzip',
      ].every((e) => e),
    );

    return [
      'curl',
      '-X $method',
      for (final header in {...?request?.headers?.entries})
        if (header.value.toString().isNotEmpty)
          '-H \'${header.key}: ${header.value.toString()}\'',
      if (body != null && body.isNotEmpty && body != 'null')
        '--data \'${body.replaceAll('\n', r'\n')}\'',
      if (compressed?.isNotEmpty == true) '--compressed',
      '\'${uri.toString()}\'',
    ].join(' ');
  }
}
