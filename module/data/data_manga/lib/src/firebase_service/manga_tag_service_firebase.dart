import 'package:cloud_firestore/cloud_firestore.dart';
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

  MangaTagServiceFirebase({required FirebaseApp app}): _app = app;

  @override
  Future<Result<List<MangaTag>>> list() async {
    final value = await _ref.get();
    final data = value.docs.map((e) => MangaTag.fromJson(e.data())).toList();
    return Success(data);
  }
}