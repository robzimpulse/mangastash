import 'package:dio/dio.dart';

abstract class Result<T> {}

class Error<T> extends Result<T> {
  late final Exception _error;

  Exception get error => _error;

  Error(Object error) {
    if (error is DioError && error.error is! DioError && error.error is Exception) {
      // there is a chance that DioError.error is instance of DioError
      // which will cause stack overflow error
      _error = error.error as Exception;
    } else if (error is Exception && error is! DioError) {
      _error = error;
    } else {
      // to prevent stack overflow just print the class name
      // if the error class is unknown
      final message = error is String ? error : error.runtimeType.toString();
      _error = Exception('Unknown error: $message');
    }
  }
}

class Success<T> extends Result<T> {

  late final T _data;

  T get data => _data;

  Success(T data) {
    _data = data;
  }
}