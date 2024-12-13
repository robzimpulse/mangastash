import 'dart:convert';
import 'dart:io';

import '../model/http_activity_model.dart';
import 'helper.dart';

extension IntToByteExtension on int? {
  static const int bytePerLevel = 1024;
  static const String kiloByteSymbol = 'kb';

  String byteToKiloByte() {
    final value = this ?? 0;
    var result = (value / bytePerLevel);
    return '${_formatDouble(result)} $kiloByteSymbol';
  }

  double byteToKiloByteDouble() {
    final value = this ?? 0;
    var result = (value / bytePerLevel);
    return result;
  }

  String _formatDouble(double value) {
    return value.toStringAsFixed(2);
  }
}

extension JsonExtension on String? {
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

extension ActivityExtension on HttpActivityModel {
  String get getCurlCommand {
    bool compressed = false;
    final StringBuffer curlCmd = StringBuffer('curl');

    curlCmd.write(' -X $method');

    final headers = Helper.decodeRawJson(request?.headers ?? '{}');
    for (final MapEntry<String, dynamic> header in headers.entries) {
      final headerValue = header.value?.toString() ?? '';
      if (headerValue.isNotEmpty) {
        if (header.key.toLowerCase() == HttpHeaders.acceptEncodingHeader &&
            headerValue.toLowerCase() == 'gzip') {
          compressed = true;
        }

        curlCmd.write(' -H "${header.key}: $headerValue"');
      }
    }

    final String? requestBody = request?.body?.toString();
    if (requestBody != null &&
        requestBody.isNotEmpty &&
        requestBody != 'null') {
      curlCmd.write(" --data \$'${requestBody.replaceAll("\n", r"\n")}'");
    }

    final Map<String, dynamic>? queryParamMap = request?.queryParameters;
    int paramCount = queryParamMap?.keys.length ?? 0;
    final StringBuffer queryParams = StringBuffer();

    if (paramCount > 0) {
      queryParams.write('?');
      for (final MapEntry<String, dynamic> queryParam
          in queryParamMap?.entries ?? []) {
        queryParams.write('${queryParam.key}=${queryParam.value}');
        paramCount--;
        if (paramCount > 0) {
          queryParams.write('&');
        }
      }
    }

    if (server.contains('http://') || server.contains('https://')) {
      curlCmd.write(
        "${compressed ? " --compressed " : " "}"
        "${"'$server$endpoint$queryParams'"}",
      );
    } else {
      curlCmd.write(
        "${compressed ? " --compressed " : " "}"
        "${"'${secure ? 'https://' : 'http://'}$server$endpoint$queryParams'"}",
      );
    }

    return curlCmd.toString();
  }

  String get description {
    var contentTypeList = response?.headers?["content-type"];
    final isImage = contentTypeList != null &&
        contentTypeList.any((element) => element.contains('image'));

    final StringBuffer activityDetails = StringBuffer();

    activityDetails.writeln('--- Curl Command ---');
    activityDetails.writeln(getCurlCommand);

    activityDetails.writeln('\n--- HTTP Activity ---');
    activityDetails.writeln('Method: $method');
    activityDetails.writeln('Server: $server');
    activityDetails.writeln('Endpoint: $endpoint');
    activityDetails.writeln('Secure: $secure');
    activityDetails.writeln('Time: ${request?.time}');
    activityDetails.writeln('Started: ${response?.time}');
    activityDetails.writeln('Duration: ${Helper.formatTime(duration)}');
    activityDetails.writeln(
      'Bytes Sent: ${Helper.formatBytes(request?.size ?? 0)}',
    );
    activityDetails.writeln(
      'Bytes Received: ${Helper.formatBytes(response?.size ?? 0)}',
    );

    activityDetails.writeln('\n--- Request ---');
    final requestHeader = Helper.encodeRawJson(request?.headers).isJson
        ? Helper.encodeRawJson(request?.headers).prettify
        : Helper.encodeRawJson(request?.headers);
    activityDetails.writeln('Headers: $requestHeader');

    final queryParam = Helper.encodeRawJson(request?.queryParameters).isJson
        ? Helper.encodeRawJson(request?.queryParameters).prettify
        : Helper.encodeRawJson(request?.queryParameters);
    activityDetails.writeln('Query Parameters: $queryParam');

    final requestBody =
        (request?.body ?? '').isJson ? request?.body.prettify : request?.body;
    activityDetails.writeln('Body: $requestBody');

    activityDetails.writeln('\n--- Response ---');
    activityDetails.writeln('Status Code: ${response?.status}');
    activityDetails.writeln(
      'Headers: ${Helper.encodeRawJson(response?.headers)}',
    );
    final responseBody = (response?.body ?? '').isJson
        ? response?.body.prettify
        : isImage
            ? "Image Body"
            : response?.body;
    activityDetails.writeln('Body: $responseBody');

    if (error?.error != null) {
      activityDetails.writeln('\n--- Error ---');
      activityDetails.writeln('Error: ${error?.error}');
    }

    return activityDetails.toString();
  }
}
