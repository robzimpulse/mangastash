import 'package:cloud_firestore/cloud_firestore.dart';
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

  MangaServiceFirebase({required FirebaseApp app}): _app = app;

  @override
  Future<Result<List<MangaDeprecated>>> list() async {
    return Error(Exception('not implemented'));
  }
}