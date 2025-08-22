import 'result.dart';

class Success<T> extends Result<T> {
  final T data;

  Success(this.data);
}