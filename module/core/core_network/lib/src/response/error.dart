import 'result.dart';

class Error<T> extends Result<T> {
  final ApiException error;

  Error(Object error)
    : error =
          (error is ApiException)
              ? error
              : ApiException(original: Exception(error.toString()));
}

class ApiException implements Exception {
  final int? code;

  final String? message;

  final Exception original;

  ApiException({this.code, this.message, required this.original});

  @override
  String toString() {
    final code = this.code;
    final message = this.message;

    if (message != null) {
      return [
        runtimeType.toString(),
        if (code != null) '[$code]',
        ':',
        message,
      ].join(' ');
    }

    return original.toString();
  }
}
