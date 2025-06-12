import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

mixin SyncTagsMixin {
  Future<List<Tag>> sync({
    required TagDao dao,
    required List<Tag> values,
    required LogBox logBox,
  }) async {

    final data = [
      for (final value in values)
        Tag.fromDrift(await dao.add(value: value.toDrift)),
    ];

    logBox.log(
      'Insert & Update Tag',
      extra: {
        'before count': values.length,
        'after count': data.length,
        'before data': [...values.map((e) => e.toJson())],
        'after data': [...data.map((e) => e.toJson())],
      },
      name: 'Sync Process',
    );

    return data;
  }
}