import 'package:entity_manga/entity_manga.dart';

abstract interface class DataService<T extends BaseModel> {

  Future<T> sync({required T value});

  Future<T> add({required T value});

  Future<T?> get({required String id});

  Future<T> update({
    required String? key,
    required Future<T> Function(T value) update,
    required Future<T> Function() ifAbsent,
  });

  Future<List<T>> search({required T value});

  Stream<T?> stream({required String id});
}