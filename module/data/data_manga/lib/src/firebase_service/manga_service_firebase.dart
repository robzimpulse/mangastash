import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

import '../service/manga_service.dart';

class MangaServiceFirebase implements MangaService {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'manga',
  );

  MangaServiceFirebase({required FirebaseApp app}) : _app = app;

  @override
  Future<void> add(Manga value) async {
    final id = value.id;
    if (id == null) return;
    await _ref.doc(id).update(value.toJson());
  }

  @override
  Future<void> update(Manga value) async {
    await add(value);
  }

  @override
  Future<Result<List<Manga>>> list() async {
    final value = await _ref.get();
    final data = value.docs.map((e) => Manga.fromJson(e.data())).toList();
    return Success(data);
  }

  @override
  Future<Result<Pagination<Manga>>> search({
    String? title,
    String? author,
    String? status,
    String? description,
    int limit = 30,
    int? offset,
  }) async {
    Query<Map<String, dynamic>> queries = _ref;

    if (title != null) {
      queries = queries.where('title', isEqualTo: title);
    }

    if (title != null) {
      queries = queries.where('author', isEqualTo: author);
    }

    if (title != null) {
      queries = queries.where('status', isEqualTo: status);
    }

    if (title != null) {
      queries = queries.where('description', isEqualTo: description);
    }

    if (offset != null) {
      queries = queries.startAfter([offset]);
    }

    final count = await queries.count().get();
    final data = await queries.limit(limit).get();

    return Success(
      Pagination<Manga>(
        data: data.docs
            .map((e) => Manga.fromJson(e.data()).copyWith(id: e.id))
            .toList(),
        limit: limit,
        offset: data.docs.lastOrNull?.id,
        total: count.count,
      ),
    );
  }
}
