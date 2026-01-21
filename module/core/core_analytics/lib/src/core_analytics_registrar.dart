import 'package:log_box/log_box.dart';
import 'package:log_box_dio_logger/log_box_dio_logger.dart';
import 'package:log_box_in_app_webview_logger/log_box_in_app_webview_logger.dart';
import 'package:log_box_navigation_logger/log_box_navigation_logger.dart';
import 'package:log_box_persistent_storage_drift/log_box_persistent_storage_drift.dart';
import 'package:service_locator/service_locator.dart';

class CoreAnalyticsRegistrar extends Registrar {
  @override
  Future<void> register(ServiceLocator locator) async {
    final start = DateTime.timestamp();
    locator.registerSingleton(
      LogBox(
        storage: Storage(
          liveDataStorage: MemoryStorage(capacity: 100),
          persistentDataStorage: DriftPersistentStorage(
            executor: await Executor.adaptive(),
            decoder: {
              (LogEntryModel).toString(): LogEntryModel.fromJson,
              (WebviewEntryModel).toString(): WebviewEntryModel.fromJson,
              (NavigationEntryModel).toString(): NavigationEntryModel.fromJson,
              (TraceLogEntryModel).toString(): TraceLogEntryModel.fromJson,
              (NetworkEntryModel).toString(): NetworkEntryModel.fromJson,
            },
          ),
        ),
      ),
    );
    // TODO: add analytics dependency here
    final end = DateTime.timestamp();
    locator<LogBox>().log(
      'Register ${runtimeType.toString()}',
      id: runtimeType.toString(),
      name: 'Services',
      extra: {
        'start': start.toIso8601String(),
        'finish': end.toIso8601String(),
        'duration': end.difference(start).toString(),
      },
    );
  }
}
