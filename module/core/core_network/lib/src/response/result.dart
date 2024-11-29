import 'package:dio/dio.dart';

abstract class Result<T> {}

class Error<T> extends Result<T> {
  late final Exception _error;

  Exception get error => _error;

  num? get statusCode {
    if (error is DioException) {
      return (error as DioException?)?.response?.statusCode;
    }
    return null;
  }

  Error(Object error) {
    if (error is DioException && error.error is Exception) {
      _error = error.error as Exception;
    } else if (error is Exception) {
      _error = error;
    } else {
      _error = Exception('Unknown error: $error');
    }
  }
}

class Success<T> extends Result<T> {
  late final T _data;

  T get data => _data;

  Success(T data): _data = data;
}
