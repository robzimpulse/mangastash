import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';

import '../model/manga_firebase.dart';
import '../util/typedef.dart';

class MangaServiceFirebase {
  final CollectionReference<Map<String, dynamic>> _ref;
  final LoggerCallback? _logger;

  MangaServiceFirebase({
    required FirebaseApp app,
    LoggerCallback? logger,
  })  : _ref = FirebaseFirestore.instanceFor(app: app).collection('mangas'),
        _logger = logger;

  // Future<MangaFirebase> sync({required MangaFirebase value}) async {
  //   final founds = await search(value: value);
  //
  //   final match = founds
  //       .sorted((a, b) => value.compareTo(a) - value.compareTo(b))
  //       .lastOrNull;
  //
  //   if (founds.length > 1) {
  //     _logger?.call(
  //       'Duplicate entry',
  //       extra: {
  //         'value': value.toJson(),
  //         'match': match?.toJson(),
  //         'similarity': value.similarity(match),
  //         'duplicated': founds.map((e) => e.toJson()).toList(),
  //       },
  //       name: runtimeType.toString(),
  //     );
  //   }
  //
  //   return await update(
  //     key: match?.id ?? value.id,
  //     update: (old) async => value.merge(old),
  //     ifAbsent: () async => value,
  //   );
  // }

  Future<MangaFirebase> add({required MangaFirebase value}) async {
    final id = value.id;

    if (id == null) {
      final ref = await _ref.add(value.toJson());
      final data = value.copyWith(id: ref.id);
      await ref.update(data.toJson());

      _logger?.call(
        'Add new entry',
        extra: {'value': data.toJson()},
        name: runtimeType.toString(),
      );
      return data;
    }

    _logger?.call(
      'Update existing entry',
      extra: {'value': value.toJson()},
      name: runtimeType.toString(),
    );

    await _ref.doc(id).set(value.toJson());
    return value;
  }

  Future<void> delete({required MangaFirebase value}) {
    return _ref.doc(value.id).delete();
  }

  Future<MangaFirebase> update({
    required String? key,
    required Future<MangaFirebase> Function(MangaFirebase value) update,
    required Future<MangaFirebase> Function() ifAbsent,
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
      _logger?.call(
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

  Future<MangaFirebase?> get({required String id}) async {
    final value = (await _ref.doc(id).get()).data();
    _logger?.call(
      'Get entry',
      extra: {'value': value},
      name: runtimeType.toString(),
    );
    if (value == null) return null;
    return MangaFirebase.fromJson(value).copyWith(id: id);
  }

  Future<List<MangaFirebase>> search({
    List<MangaFirebase> values = const [],
  }) async {
    final Map<String, List<dynamic>> params = {};
    for (final value in values) {
      final json = value.toJson();
      for (final key in json.keys) {
        params.update(key, (old) => old..add(json[key]), ifAbsent: () => []);
      }
    }

    final data = <MangaFirebase>{};

    for (final param in params.entries) {
      final array = param.value.whereType<String>().nonEmpty.toList();
      if (array.isNotEmpty) {
        final ref = _ref.where(param.key, whereIn: array).orderBy(param.key);
        final total = (await ref.count().get()).count ?? 0;
        DocumentSnapshot? offsetId;

        do {
          final result = (offsetId == null)
              ? await (ref.limit(100).get())
              : await (ref.startAfterDocument(offsetId).limit(100).get());

          data.addAll(result.docs.map((e) => MangaFirebase.fromFirebase(e)));
          offsetId = result.docs.lastOrNull;
        } while (data.length < total);
      }
    }

    return [...data];
  }

  Stream<MangaFirebase?> stream({required String id}) {
    final stream = _ref.doc(id).snapshots();
    return stream.map(
      (e) {
        final json = e.data();
        return json == null
            ? null
            : MangaFirebase.fromJson(json).copyWith(id: e.id);
      },
    );
  }
}
