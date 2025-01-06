import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaTagServiceFirebase {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'tags',
  );

  MangaTagServiceFirebase({required FirebaseApp app}) : _app = app;

  Future<MangaTag> add(MangaTag value) async {
    final ref = await _ref.add(value.toJson());
    final data = value.copyWith(id: ref.id);
    await ref.update(data.toJson());
    return data;
  }

  Future<MangaTag> update(MangaTag value) async {
    await _ref.doc(value.id).set(value.toJson());
    return value;
  }

  Future<bool> exists(String id) async {
    return (await _ref.doc(id).get()).exists;
  }

  Future<Result<List<MangaTag>>> list() async {
    final value = await _ref.get();
    final data = value.docs.map((e) => MangaTag.fromJson(e.data())).toList();
    return Success(data);
  }

  Future<Pagination<MangaTag>> search({
    List<String>? name,
    int limit = 30,
    int? offset,
  }) async {
    Query<Map<String, dynamic>> queries = _ref;

    if (name != null) {
      queries = queries.where('name', whereIn: name);
    }

    if (offset != null) {
      queries = queries.startAfter([offset]);
    }

    final count = await queries.count().get();
    final data = await queries.limit(limit).get();

    return Pagination<MangaTag>(
      data: data.docs
          .map((e) => MangaTag.fromJson(e.data()).copyWith(id: e.id))
          .toList(),
      limit: limit,
      offset: data.docs.lastOrNull?.id,
      total: count.count,
    );
  }
}
