import '../../core_network.dart';

class DioErrorTransformerInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err.copyWith(error: _transformError(err)), handler);
  }

  Exception _transformError(DioException e) {
    final data = e.response?.data;
    final code = e.response?.statusCode;
    final message = e.response?.statusMessage ?? e.message;

    if (e.type == DioExceptionType.badResponse) {
      if (data is ResponseBody) {
        return ApiException(
          code: data.statusCode,
          message: data.statusMessage ?? message,
          original: e,
        );
      }
    }

    return ApiException(code: code, message: message, original: e);
  }
}
