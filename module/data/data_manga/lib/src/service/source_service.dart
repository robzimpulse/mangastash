import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';

class SourceService {
  final FirebaseApp _app;

  late final FirebaseFirestore _db = FirebaseFirestore.instanceFor(app: _app);

  late final CollectionReference<Map<String, dynamic>> _ref = _db.collection(
    'sources',
  );

  SourceService({required FirebaseApp app}): _app = app;

  Future<List<MangaSource>> list() async {
    final value = await _ref.get();
    return value.docs.map((e) => MangaSource.fromJson(e.data())).toList();
  }
}
