import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:core_network/core_network.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../data_manga.dart';

class SourceServiceFirebase implements SourceService {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'sources',
  );

  SourceServiceFirebase({required FirebaseApp app}) : _app = app;

  @override
  Future<Result<List<MangaSource>>> list() async {
    final path = await _ref.get();
    final docs = path.docs;
    return Success(
      docs
          .map((e) => MangaSource.fromJson(e.data()).copyWith(id: e.id))
          .toList(),
    );
  }

  @override
  Future<Result<MangaSource>> get(String id) async {
    final path = await _ref.doc(id).get();
    final data = path.data();
    if (data == null) {
      return Error(Exception('data not found'));
    }

    return Success(MangaSource.fromJson(data).copyWith(id: id));
  }

  @override
  Future<Result<Pagination<MangaSource>>> search({
    String? name,
    String? url,
    int limit = 30,
    int? offset,
  }) async {
    Query<Map<String, dynamic>> queries = _ref;

    if (name != null) {
      queries = queries.where('name', isEqualTo: name);
    }

    if (url != null) {
      queries = queries.where('url', isEqualTo: url);
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
