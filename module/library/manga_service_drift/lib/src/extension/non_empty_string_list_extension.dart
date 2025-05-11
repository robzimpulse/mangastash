extension NonEmptyStringListExtension on List<String> {

  List<String> get nonEmpty => where((e) => e.isNotEmpty).toList();

}