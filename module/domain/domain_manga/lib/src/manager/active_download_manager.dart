import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:log_box/log_box.dart';
import 'package:rxdart/rxdart.dart';

import '../use_case/chapter/listen_active_download_use_case.dart';
import '../use_case/chapter/listen_progress_download_use_case.dart';

class ActiveDownloadManager
    implements ListenActiveDownloadUseCase, ListenProgressDownloadUseCase {
  final BehaviorSubject<Set<DownloadChapterKey>> _active;
  final FileDownloader _fileDownloader;
  final LogBox _log;
  StreamSubscription? _streamSubscription;

  static Future<ActiveDownloadManager> create({
    required FileDownloader fileDownloader,
    required LogBox log,
  }) async {
    final records = await fileDownloader.database.allRecords();
    final Map<DownloadChapterKey, List<TaskRecord>> activeDownloadRecord = {};

    for (final record in records) {
      if (record.status.isFinalState) continue;
      final key = DownloadChapterKey.fromJsonString(record.group);
      (activeDownloadRecord[key] ??= []).add(record);
    }

    return ActiveDownloadManager(
      fileDownloader: fileDownloader,
      log: log,
      activeDownloadKey: Set.of(activeDownloadRecord.keys),
    );
  }

  ActiveDownloadManager({
    required Set<DownloadChapterKey> activeDownloadKey,
    required FileDownloader fileDownloader,
    required LogBox log,
  })  : _active = BehaviorSubject.seeded(activeDownloadKey),
        _log = log,
        _fileDownloader = fileDownloader {
    _streamSubscription = fileDownloader.updates.distinct().listen(_onUpdate);
  }

  void dispose() {
    _streamSubscription?.cancel();
  }

  void _onUpdate(TaskUpdate event) async {
    final task = event.task;
    final key = DownloadChapterKey.fromJsonString(event.task.group);

    if (event is TaskStatusUpdate) {
      if (event.status.isFinalState) {
        final records = await _fileDownloader.database.allRecords(
          group: task.group,
        );
        if (records.every((record) => record.status.isFinalState)) {
          _active.add(Set.of(_active.value)..remove(key));
          _log.log(
            'Removing ${task.group} from active download',
            name: runtimeType.toString(),
            time: DateTime.now(),
          );
        }
      } else {
        _active.add(Set.of(_active.value)..add(key));
        _log.log(
          'Adding ${task.group} to active download',
          name: runtimeType.toString(),
          time: DateTime.now(),
        );
      }
    }

    if (event is TaskProgressUpdate) {
      _active.add(Set.of(_active.value)..add(key));
      _log.log(
        'Adding ${task.group} to active download',
        name: runtimeType.toString(),
        time: DateTime.now(),
      );
    }
  }

  @override
  ValueStream<Set<DownloadChapterKey>> get activeDownloadStream =>
      _active.stream;

  @override
  ValueStream<DownloadChapterProgress> progress(DownloadChapterKey key) {
    final group = key.toJsonString();
    final stream = _fileDownloader.updates.asBroadcastStream();
    final update = stream.where((task) => task.task.group == group);
    final Stream<Map<String, TaskUpdate>> chapter = update.scan(
      (result, current, _) => Map.of(result)
        ..update(
          current.task.taskId,
          (old) {
            if (current is TaskProgressUpdate && old is TaskProgressUpdate) {
              if (current.progress > old.progress) {
                return current;
              } else {
                return old;
              }
            }

            return current;
          },
          ifAbsent: () => current,
        ),
      {},
    );

    final result = chapter.map(
      (chapter) => DownloadChapterProgress(
        total: chapter.length,
        progress: 0,
      ),
    );

    return result.shareValue();
  }
}
