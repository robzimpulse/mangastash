import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../model/manga_source_firebase.dart';

class MangaSourceServiceFirebase {
  final CollectionReference<Map<String, dynamic>> _ref;

  MangaSourceServiceFirebase({
    required FirebaseApp app,
  }) : _ref = FirebaseFirestore.instanceFor(app: app).collection('sources');

  Stream<Map<String, MangaSourceFirebase>> get stream {
    final stream = _ref.snapshots();
    return stream.map(
      (event) => Map.fromEntries(
        event.docs.map(
          (doc) => MapEntry(
            doc.id,
            MangaSourceFirebase.fromJson(doc.data()).copyWith(id: doc.id),
          ),
        ),
      ),
    );
  }
}
