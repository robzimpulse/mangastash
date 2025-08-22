import 'result.dart';

class Error<T> extends Result<T> {
  late final Exception error;

  Error(Object error) {
    if (error is Exception) {
      this.error = error;
    } else {
      this.error = Exception(error.toString());
    }
  }
}
