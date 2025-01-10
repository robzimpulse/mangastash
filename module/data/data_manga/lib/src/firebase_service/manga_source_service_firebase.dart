import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaSourceServiceFirebase {
  final FirebaseApp _app;

  late final _db = FirebaseFirestore.instanceFor(app: _app);

  late final _ref = _db.collection('sources');

  late final _stream = _ref.snapshots();

  MangaSourceServiceFirebase({required FirebaseApp app}) : _app = app;

  // Future<void> add(MangaSource value) async {
  //   final id = value.id;
  //   if (id == null) return;
  //   await _ref.doc(id).set(value.toJson());
  // }
  //
  // Future<void> update(MangaSource value) async {
  //   final id = value.id;
  //   if (id == null) return;
  //   await _ref.doc(id).update(value.toJson());
  // }
  //
  // Future<bool> exists(String id) async {
  //   return (await _ref.doc(id).get()).exists;
  // }
  //
  // Future<Result<List<MangaSource>>> list() async {
  //   final path = await _ref.get();
  //   final docs = path.docs;
  //   return Success(
  //     docs
  //         .map((e) => MangaSource.fromJson(e.data()).copyWith(id: e.id))
  //         .toList(),
  //   );
  // }
  //
  // Future<MangaSource?> get(String id) async {
  //   final value = (await _ref.doc(id).get()).data();
  //   if (value == null) return null;
  //   return MangaSource.fromJson(value);
  // }

  Stream<List<MangaSource>> stream() {
    return _stream.map(
      (event) => List.of(
        event.docs.map(
          (doc) => MangaSource.fromJson(doc.data()).copyWith(id: doc.id),
        ),
      ),
    );
  }

  // Future<Result<Pagination<MangaSource>>> search({
  //   MangaSourceEnum? name,
  //   String? url,
  //   String? iconUrl,
  //   int limit = 30,
  //   int? offset,
  // }) async {
  //   Query<Map<String, dynamic>> queries = _ref;
  //
  //   if (name != null) {
  //     queries = queries.where('name', isEqualTo: name.value);
  //   }
  //
  //   if (url != null) {
  //     queries = queries.where('url', isEqualTo: url);
  //   }
  //
  //   if (iconUrl != null) {
  //     queries = queries.where('iconUrl', isEqualTo: iconUrl);
  //   }
  //
  //   if (offset != null) {
  //     queries = queries.startAfter([offset]);
  //   }
  //
  //   final count = await queries.count().get();
  //   final data = await queries.limit(limit).get();
  //
  //   return Success(
  //     Pagination<MangaSource>(
  //       data: data.docs
  //           .map((e) => MangaSource.fromJson(e.data()).copyWith(id: e.id))
  //           .toList(),
  //       limit: limit,
  //       offset: data.docs.lastOrNull?.id,
  //       total: count.count,
  //     ),
  //   );
  // }
}
