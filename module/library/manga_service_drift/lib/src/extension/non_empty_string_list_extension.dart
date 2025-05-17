extension NonEmptyStringListExtension on List<String> {
  List<String> get nonEmpty => where((e) => e.isNotEmpty).toList();
}

extension DistincStringListExtension on List<String> {
  List<String> get distinct => {...this}.toList();
}