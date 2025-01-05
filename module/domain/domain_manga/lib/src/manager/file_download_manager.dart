import 'package:background_downloader/background_downloader.dart';
import 'package:log_box/log_box.dart';

class FileDownloadManager {
  static Future<FileDownloader> create({required LogBox log}) async {
    final fileDownloader = FileDownloader();

    await fileDownloader.configure(
      globalConfig: [
        (Config.requestTimeout, const Duration(minutes: 1)),
        (Config.resourceTimeout, const Duration(minutes: 10)),
        (Config.holdingQueue, (null, 5, null)),
      ],
      androidConfig: [
        (Config.useCacheDir, Config.whenAble),
      ],
      iOSConfig: [
        (Config.excludeFromCloudBackup, Config.always),
      ],
    );

    await fileDownloader.trackTasks();

    return fileDownloader.registerCallbacks(
      taskNotificationTapCallback: (task, notificationType) => log.log(
        'Tap Notification for ${task.taskId} with $notificationType',
        name: 'FileDownloadManager',
      ),
    );
  }
}
