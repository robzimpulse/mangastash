extension DistinctList<X> on List<X> {
  List<X> distinct() => <X>{...this}.toList();
}

extension NullableGeneric<T> on T? {
  T or(T replace) => this ?? replace;

  T? orNull(T? replace) => this ?? replace;

  R? let<R>(R? Function(T) applicator) {
    final self = this;
    return self != null ? applicator(self) : null;
  }

  R? castOrNull<R>() {
    final self = this;
    if (self == null) return null;
    return self is R ? self as R : null;
  }

  R castOrFallback<R>(R fallback) => castOrNull() ?? fallback;
}
