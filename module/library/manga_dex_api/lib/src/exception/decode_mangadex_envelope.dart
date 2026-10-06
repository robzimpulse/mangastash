import 'dart:convert';

import 'package:dio/dio.dart';

import '../exception/server_exception.dart';

MangadexServerException? decodeMangadexEnvelope(Object error) {
  if (error is! DioException) return null;
  final response = error.response;
  if (response == null) return null;

  dynamic data = response.data;
  Map<String, dynamic>? parsed;

  if (data is Map<String, dynamic>) {
    parsed = data;
  } else if (data is String) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        parsed = decoded;
      }
    } catch (_) {
      return null;
    }
  } else {
    return null;
  }

  if (parsed == null) return null;
  if (parsed['result'] != 'error') return null;
  final errors = parsed['errors'];
  if (errors is! List || errors.isEmpty) return null;
  try {
    return MangadexServerException(parsed);
  } catch (_) {
    // A malformed errors entry (e.g. a non-object element) must not replace
    // the original network error with a deserialization throw — treat the
    // body as a non-envelope and fall through to the generic Dio mapping.
    return null;
  }
}
