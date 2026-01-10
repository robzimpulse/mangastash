extension NonEmptyStringListExtension on List<String> {
  List<String> get nonEmpty => where((e) => e.isNotEmpty).toList();
}

extension DistinctListExtension<T> on List<T> {
  List<T> get distinct => {...this}.toList();
}
