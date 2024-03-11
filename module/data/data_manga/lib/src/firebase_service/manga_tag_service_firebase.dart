import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

import '../service/manga_tag_service.dart';

class MangaTagServiceFirebase implements MangaTagService {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'tag',
  );

  MangaTagServiceFirebase({required FirebaseApp app}) : _app = app;

  @override
  Future<void> add(MangaTag value) async {
    final id = value.id;
    if (id == null) return;
    await _ref.doc(id).set(value.toJson());
  }

  @override
  Future<void> update(MangaTag value) async {
    final id = value.id;
    if (id == null) return;
    await _ref.doc(id).update(value.toJson());
  }

  @override
  Future<bool> exists(String id) async {
    return (await _ref.doc(id).get()).exists;
  }

  @override
  Future<Result<List<MangaTag>>> list() async {
    final value = await _ref.get();
    final data = value.docs.map((e) => MangaTag.fromJson(e.data())).toList();
    return Success(data);
  }

  @override
  Future<Result<Pagination<MangaTag>>> search({
    String? name,
    int limit = 30,
    int? offset,
  }) async {
    Query<Map<String, dynamic>> queries = _ref;

    if (name != null) {
      queries = queries.where('name', isEqualTo: name);
    }

    if (offset != null) {
      queries = queries.startAfter([offset]);
    }

    final count = await queries.count().get();
    final data = await queries.limit(limit).get();

    return Success(
      Pagination<MangaTag>(
        data: data.docs
            .map((e) => MangaTag.fromJson(e.data()).copyWith(id: e.id))
            .toList(),
        limit: limit,
        offset: data.docs.lastOrNull?.id,
        total: count.count,
      ),
    );
  }
}
