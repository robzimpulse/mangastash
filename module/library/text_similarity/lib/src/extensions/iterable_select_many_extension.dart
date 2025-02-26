extension IterableSelectMany<T> on Iterable<T> {

  // ignore: avoid_shadowing_type_parameters
  Iterable<dynamic> selectMany<T>(int n) sync* {
    if (n > length) {
      throw ArgumentError('N more then elements in collection');
    }

    for(var i = 0; i < length; i+=n) {
      yield skip(i).take(n).toList();
    }
  }
}