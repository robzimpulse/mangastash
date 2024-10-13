abstract class Result<T> {}

class Error<T> extends Result<T> {
  late final Exception _error;

  Exception get error => _error;

  Error(Object error) {
    if (error is Exception) {
      _error = error;
    } else {
      final message = error is String ? error : error.runtimeType.toString();
      _error = Exception('Unknown error: $message');
    }
  }
}

class Success<T> extends Result<T> {
  late final T _data;

  T get data => _data;

  Success(T data): _data = data;
}
