import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MangaChapterServiceFirebase {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'chapters',
  );

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream =
      _ref.snapshots();

  MangaChapterServiceFirebase({required FirebaseApp app}) : _app = app;

  // Future<void> update(MangaChapter value) async {
  //   await _ref.doc(value.id).set(value.toJson());
  // }
  //
  // Future<bool> exists(String id) async {
  //   return (await _ref.doc(id).get()).exists;
  // }
  //
  // Future<MangaChapter> get(String id) async {
  //   final value = (await _ref.doc(id).get()).data();
  //   if (value == null) throw Exception('Data not Found');
  //   return MangaChapter.fromJson(value);
  // }
  //
  // Future<Result<List<MangaChapter>>> list() async {
  //   final value = await _ref.get();
  //   final data = value.docs.map((e) => MangaChapter.fromJson(e.data())).toList();
  //   return Success(data);
  // }
  //
  // Future<Result<Pagination<MangaChapter>>> search({
  //   String? mangaId,
  //   String? title,
  //   String? volume,
  //   String? chapter,
  //   String? readableAt,
  //   int limit = 30,
  //   int? offset,
  // }) async {
  //   Query<Map<String, dynamic>> queries = _ref;
  //
  //   if (title != null) {
  //     queries = queries.where('title', isEqualTo: title);
  //   }
  //
  //   if (mangaId != null) {
  //     queries = queries.where('mangaId', isEqualTo: mangaId);
  //   }
  //
  //   if (volume != null) {
  //     queries = queries.where('volume', isEqualTo: volume);
  //   }
  //
  //   if (readableAt != null) {
  //     queries = queries.where('readableAt', isEqualTo: readableAt);
  //   }
  //
  //   if (chapter != null) {
  //     queries = queries.where('chapter', isEqualTo: chapter);
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
  //     Pagination<MangaChapter>(
  //       data: data.docs
  //           .map((e) => MangaChapter.fromJson(e.data()).copyWith(id: e.id))
  //           .toList(),
  //       limit: limit,
  //       offset: data.docs.lastOrNull?.id,
  //       total: count.count,
  //     ),
  //   );
  // }
}
