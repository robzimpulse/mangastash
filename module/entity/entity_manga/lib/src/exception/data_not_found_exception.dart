class DataNotFoundException implements Exception {

  DataNotFoundException();

  @override
  String toString() => '$runtimeType : Data not found';

}