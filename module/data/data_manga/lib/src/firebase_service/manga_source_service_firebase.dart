import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaSourceServiceFirebase {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'sources',
  );

  MangaSourceServiceFirebase({required FirebaseApp app}) : _app = app;

  Future<void> add(MangaSource value) async {
    final id = value.id;
    if (id == null) return;
    await _ref.doc(id).set(value.toJson());
  }

  Future<void> update(MangaSource value) async {
    final id = value.id;
    if (id == null) return;
    await _ref.doc(id).update(value.toJson());
  }

  Future<bool> exists(String id) async {
    return (await _ref.doc(id).get()).exists;
  }

  Future<Result<List<MangaSource>>> list() async {
    final path = await _ref.get();
    final docs = path.docs;
    return Success(
      docs
          .map((e) => MangaSource.fromJson(e.data()).copyWith(id: e.id))
          .toList(),
    );
  }

  Future<Result<MangaSource>> get(String id) async {
    final path = await _ref.doc(id).get();
    final data = path.data();
    if (data == null) {
      return Error(Exception('data not found'));
    }

    return Success(MangaSource.fromJson(data).copyWith(id: id));
  }

  Stream<List<MangaSource>> stream() {
    final stream = _ref.snapshots();
    return stream.map((event) {
      final values = event.docs;

      List<MangaSource> data = [];

      for (final value in values) {
        final id = value.id;
        final json = value.data();
        data.add(MangaSource.fromJson(json).copyWith(id: id));
      }

      return data;
    });
  }

  Future<Result<Pagination<MangaSource>>> search({
    MangaSourceEnum? name,
    String? url,
    String? iconUrl,
    int limit = 30,
    int? offset,
  }) async {
    Query<Map<String, dynamic>> queries = _ref;

    if (name != null) {
      queries = queries.where('name', isEqualTo: name.value);
    }

    if (url != null) {
      queries = queries.where('url', isEqualTo: url);
    }

    if (iconUrl != null) {
      queries = queries.where('iconUrl', isEqualTo: iconUrl);
    }

    if (offset != null) {
      queries = queries.startAfter([offset]);
    }

    final count = await queries.count().get();
    final data = await queries.limit(limit).get();

    return Success(
      Pagination<MangaSource>(
        data: data.docs
            .map((e) => MangaSource.fromJson(e.data()).copyWith(id: e.id))
            .toList(),
        limit: limit,
        offset: data.docs.lastOrNull?.id,
        total: count.count,
      ),
    );
  }
}
