import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:log_box/log_box.dart';

class MangaTagServiceFirebase {
  final CollectionReference<Map<String, dynamic>> _ref;
  final LogBox _logBox;

  MangaTagServiceFirebase({
    required FirebaseApp app,
    required LogBox logBox,
  })  : _ref = FirebaseFirestore.instanceFor(app: app).collection('tags'),
        _logBox = logBox;

  Future<MangaTag> sync({required MangaTag value}) async {
    final founds = await search(value: value);

    if (founds.length > 1) {
      _logBox.log(
        'Duplicate entry',
        extra: {
          'value': value.toJson(),
          'duplicated': founds.map((e) => e.toJson()).toList(),
        },
        name: runtimeType.toString(),
      );
    }

    final match = founds
        .sorted((a, b) => value.compareTo(a) - value.compareTo(b))
        .lastOrNull;

    return await update(
      key: match?.id ?? value.id,
      update: (old) async => value.merge(old),
      ifAbsent: () async => value,
    );
  }

  Future<MangaTag> add({required MangaTag value}) async {
    final id = value.id;

    if (id == null) {
      final ref = await _ref.add(value.toJson());
      final data = value.copyWith(id: ref.id);
      await ref.update(data.toJson());
      _logBox.log(
        'Update new entry',
        extra: {'value': value.toJson()},
        name: runtimeType.toString(),
      );
      return data;
    }

    _logBox.log(
      'Update new entry',
      extra: {'value': value.toJson()},
      name: runtimeType.toString(),
    );
    await _ref.doc(id).set(value.toJson());
    return value;
  }

  Future<MangaTag?> get({required String id}) async {
    final value = (await _ref.doc(id).get()).data();
    _logBox.log(
      'Get entry',
      extra: {'value': value},
      name: runtimeType.toString(),
    );
    if (value == null) return null;
    return MangaTag.fromJson(value).copyWith(id: id);
  }

  Future<MangaTag> update({
    required String? key,
    required Future<MangaTag> Function(MangaTag value) update,
    required Future<MangaTag> Function() ifAbsent,
  }) async {
    if (key == null) {
      return add(value: await ifAbsent());
    }

    final data = await get(id: key);
    if (data == null) {
      return add(value: await ifAbsent());
    }

    final updated = await update(data);
    if (updated != data) {
      _logBox.log(
        'Update existing entry',
        extra: {
          'value': data.toJson(),
          'updated': updated.toJson(),
        },
        name: runtimeType.toString(),
      );
      await _ref.doc(key).set(updated.toJson());
    }
    return updated;
  }

  Future<List<MangaTag>> search({
    required MangaTag value,
  }) async {
    final List<MangaTag> data = [];
    final ref = _ref.where('name', isEqualTo: value.name).orderBy('name');
    final total = (await ref.count().get()).count ?? 0;
    DocumentSnapshot? offset;

    do {
      final result = (offset == null)
          ? await (ref.limit(100).get())
          : await (ref.startAfterDocument(offset).limit(100).get());
      data.addAll(
        result.docs.map((e) => MangaTag.fromJson(e.data()).copyWith(id: e.id)),
      );
      offset = result.docs.lastOrNull;
    } while (data.length < total);

    _logBox.log(
      'Search existing entry',
      extra: {
        'value': value.toJson(),
        'matched': data.map((e) => e.toJson()).toList(),
      },
      name: runtimeType.toString(),
    );

    return data;
  }
}
