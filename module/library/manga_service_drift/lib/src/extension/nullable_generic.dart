extension NullableGeneric<T> on T? {
  T or(T replace) => this ?? replace;

  T? orNull(T? replace) => this ?? replace;

  R? let<R>(R? Function(T) applicator) {
    final self = this;
    return self != null ? applicator(self) : null;
  }

  R? castOrNull<R>() => this is R ? this as R : null;

  R castOrFallback<R>(R fallback) => castOrNull() ?? fallback;
}
