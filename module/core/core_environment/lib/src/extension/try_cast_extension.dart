extension DistinctList<X> on List<X> {
  List<X> distinct() => <X>{...this}.toList();
}

extension NullableGeneric<T> on T? {
  T or(T replace) {
    final self = this;
    return (self == null) ? replace : self;
  }

  R? let<R>(R Function(T) applicator) {
    final self = this;
    return self != null ? applicator(self) : null;
  }

  R? castOrNull<R>() {
    final self = this;
    return self is R ? self : null;
  }

  R? castOrFallback<R>(R fallback) {
    final self = this as R?;
    return self ?? fallback;
  }
}
