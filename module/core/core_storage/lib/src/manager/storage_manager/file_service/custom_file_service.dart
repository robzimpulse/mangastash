/// File service implementation for cache managers backed by Dio and headless webview fallback.
///
/// Fetches files using Dio stream responses, optionally rejecting `text/html` responses
/// (such as bot challenge or Cloudflare interstitials) when [rejectHtml] is true so that
/// the request falls back to [HeadlessWebviewUseCase.image] rather than caching HTML as images.
///
/// Usage:
/// Instantiate with Dio and HeadlessWebviewUseCase getters, optionally setting [rejectHtml] to true
/// for image caches:
/// `CustomFileService(dio: () => locator(), headlessWebviewUseCase: () => locator(), rejectHtml: true);`
library;

import 'package:core_network/core_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:universal_io/io.dart';

import 'dio_get_response.dart';
import 'image_base64_get_response.dart';

class CustomFileService extends FileService {
  final ValueGetter<Dio> _dio;
  final ValueGetter<HeadlessWebviewUseCase> _headlessWebviewUseCase;
  final bool _rejectHtml;

  CustomFileService({
    required this._dio,
    required this._headlessWebviewUseCase,
    this._rejectHtml = false,
  });

  @override
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return _getUsingDio(
      url,
      headers: headers,
    ).onError((_, __) => _getUsingBrowser(url, headers: headers));
  }

  Future<FileServiceResponse> _getUsingDio(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _dio().get<ResponseBody>(
      url,
      options: Options(
        headers: headers ?? {},
        responseType: ResponseType.stream,
      ),
    );

    if (_rejectHtml) {
      final headersMap = response.data?.headers;
      String? contentTypeHeader;
      if (headersMap != null) {
        for (final entry in headersMap.entries) {
          if (entry.key.toLowerCase() == 'content-type') {
            contentTypeHeader = entry.value.firstOrNull;
            break;
          }
        }
      }

      if (contentTypeHeader != null) {
        try {
          final contentType = ContentType.parse(contentTypeHeader);
          if (contentType.mimeType.toLowerCase() == 'text/html') {
            await response.data?.stream.listen((_) {}).cancel();
            throw HttpException(
              'HTML response rejected for image: $contentTypeHeader',
            );
          }
        } on FormatException {
          // Unparseable content type is not text/html.
        }
      }
    }

    return DioGetResponse(response);
  }

  Future<FileServiceResponse> _getUsingBrowser(
    String url, {
    Map<String, String>? headers,
  }) async {
    return ImageBase64GetResponse(
      imageBase64: await _headlessWebviewUseCase().image(url, headers: headers),
    );
  }
}
