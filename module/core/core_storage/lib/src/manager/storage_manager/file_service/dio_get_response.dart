import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/web/mime_converter.dart';
import 'package:universal_io/io.dart';

class DioGetResponse implements FileServiceResponse {
  final DateTime _receivedTime = DateTime.now();
  final Response<ResponseBody> _response;

  DioGetResponse(this._response);

  @override
  Stream<List<int>> get content => _response.data!.stream;

  @override
  int get contentLength {
    final result = int.tryParse(
      _response.headers[Headers.contentLengthHeader]?.first ?? '-1',
    );
    return result ?? -1;
  }

  @override
  String get eTag => _response.headers['etag']?.first ?? '-1';

  @override
  String get fileExtension {
    var fileExtension = '';
    final contentTypeHeader =
        _response.headers[Headers.contentTypeHeader]?.first;
    if (contentTypeHeader != null) {
      final contentType = ContentType.parse(contentTypeHeader);
      fileExtension = mimeTypes[contentType.mimeType]!;
    }
    return fileExtension;
  }

  @override
  int get statusCode => _response.statusCode!;

  @override
  DateTime get validTill {
    // Without a cache-control header we keep the file for a week
    var ageDuration = const Duration(days: 7);
    final controlHeader = _response.headers['cache-control']?.first;
    if (controlHeader != null) {
      final controlSettings = controlHeader.split(',');
      for (final setting in controlSettings) {
        final sanitizedSetting = setting.trim().toLowerCase();
        if (sanitizedSetting == 'no-cache') {
          ageDuration = const Duration();
        }
        if (sanitizedSetting.startsWith('max-age=')) {
          var validSeconds = int.tryParse(sanitizedSetting.split('=')[1]) ?? 0;
          if (validSeconds > 0) {
            ageDuration = Duration(seconds: validSeconds);
          }
        }
      }
    }

    return _receivedTime.add(ageDuration);
  }
}
