import 'package:core_network/core_network.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'dio_get_response.dart';
import 'image_base64_get_response.dart';

class CustomFileService extends FileService {
  final ValueGetter<Dio> _dio;
  final ValueGetter<HeadlessWebviewUseCase> _headlessWebviewUseCase;

  CustomFileService({
    required ValueGetter<Dio> dio,
    required ValueGetter<HeadlessWebviewUseCase> headlessWebviewUseCase,
  }) : _dio = dio,
       _headlessWebviewUseCase = headlessWebviewUseCase;

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
    return DioGetResponse(
      await _dio().get<ResponseBody>(
        url,
        options: Options(
          headers: headers ?? {},
          responseType: ResponseType.stream,
        ),
      ),
    );
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
