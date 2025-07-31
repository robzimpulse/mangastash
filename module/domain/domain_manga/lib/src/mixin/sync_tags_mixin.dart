import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';

mixin SyncTagsMixin {
  Future<List<Tag>> sync({
    required TagDao dao,
    required List<Tag> values,
    required LogBox logBox,
  }) async {
    final stopwatch = Stopwatch()..start();

    final results = await dao.adds(values: [...values.map((e) => e.toDrift)]);

    final data = [...results.map((e) => Tag.fromDrift(e)).nonNulls];

    stopwatch.stop();

    logBox.log(
      'Insert & Update Tag',
      extra: {
        'before count': values.length,
        'after count': data.length,
        'before data': [...values.map((e) => e.toJson())],
        'after data': [...data.map((e) => e.toJson())],
        'duration': stopwatch.elapsed.toString(),
      },
      name: 'Sync Process',
    );

    return data;
  }
}