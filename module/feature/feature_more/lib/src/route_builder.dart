import 'package:core_route/core_route.dart';
import 'package:flutter/widgets.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_more/ui_more.dart';

import 'route_path.dart';

class MoreRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
  }) {
    return GoRoute(
      path: MoreRoutePath.more,
      name: MoreRoutePath.more,
      pageBuilder: (context, state) => NoTransitionPage(
        child: MoreScreen.create(
          locator: locator,
          onTapSetting: (context) => context.push(MoreRoutePath.setting),
          onTapStatistic: (context) => context.push(MoreRoutePath.statistic),
          onTapBackupRestore: (context) => context.push(
            MoreRoutePath.backupRestore,
          ),
          onTapDownloadQueue: (context) => context.push(
            MoreRoutePath.downloadQueue,
          ),
        ),
      ),
    );
  }

  @override
  List<RouteBase> routes({
    required ServiceLocator locator,
    required GlobalKey<NavigatorState> rootNavigatorKey,
  }) {
    return [
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.setting,
        name: MoreRoutePath.setting,
        builder: (context, state) => SettingScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.backupRestore,
        name: MoreRoutePath.backupRestore,
        builder: (context, state) => BackupRestoreScreen.create(
          locator: locator,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.statistic,
        name: MoreRoutePath.statistic,
        builder: (context, state) => StatisticScreen.create(
          locator: locator,
        ),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.downloadQueue,
        name: MoreRoutePath.downloadQueue,
        builder: (context, state) => DownloadQueueScreen.create(
          locator: locator,
        ),
      ),
    ];
  }
}
