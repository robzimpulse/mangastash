import 'dart:convert';

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
  // String get getCurlCommand {
  //   bool compressed = false;
  //   final StringBuffer curlCmd = StringBuffer('curl');
  //
  //   curlCmd.write(' -X $method');
  //
  //   final headers = Helper.decodeRawJson(request?.headers ?? '{}');
  //   for (final MapEntry<String, dynamic> header in headers.entries) {
  //     final headerValue = header.value?.toString() ?? '';
  //     if (headerValue.isNotEmpty) {
  //       if (header.key.toLowerCase() == HttpHeaders.acceptEncodingHeader &&
  //           headerValue.toLowerCase() == 'gzip') {
  //         compressed = true;
  //       }
  //
  //       curlCmd.write(' -H "${header.key}: $headerValue"');
  //     }
  //   }
  //
  //   final String? requestBody = request?.body?.toString();
  //   if (requestBody != null &&
  //       requestBody.isNotEmpty &&
  //       requestBody != 'null') {
  //     curlCmd.write(" --data \$'${requestBody.replaceAll("\n", r"\n")}'");
  //   }
  //
  //   final Map<String, dynamic>? queryParamMap = request?.queryParameters;
  //   int paramCount = queryParamMap?.keys.length ?? 0;
  //   final StringBuffer queryParams = StringBuffer();
  //
  //   if (paramCount > 0) {
  //     queryParams.write('?');
  //     for (final MapEntry<String, dynamic> queryParam
  //         in queryParamMap?.entries ?? []) {
  //       queryParams.write('${queryParam.key}=${queryParam.value}');
  //       paramCount--;
  //       if (paramCount > 0) {
  //         queryParams.write('&');
  //       }
  //     }
  //   }
  //
  //   if (server?.contains('http://') == true ||
  //       server?.contains('https://') == true) {
  //     curlCmd.write(
  //       "${compressed ? " --compressed " : " "}"
  //       "${"'$server$endpoint$queryParams'"}",
  //     );
  //   } else {
  //     curlCmd.write(
  //       "${compressed ? " --compressed " : " "}"
  //       "${"'${secure ?? false ? 'https://' : 'http://'}$server$endpoint$queryParams'"}",
  //     );
  //   }
  //
  //   return curlCmd.toString();
  // }
}
