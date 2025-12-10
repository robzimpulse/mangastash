import 'package:core_environment/core_environment.dart';
import 'package:core_route/core_route.dart';
import 'package:feature_common/feature_common.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_more/ui_more.dart';

import 'route_path.dart';

class MoreRouteBuilder extends BaseRouteBuilder {
  @override
  GoRoute root({
    required ServiceLocator locator,
    ValueGetter<List<NavigatorObserver>>? observers,
  }) {
    return GoRoute(
      path: MoreRoutePath.more,
      name: MoreRoutePath.more,
      pageBuilder: (context, state) {
        return NoTransitionPage(
          name: MoreRoutePath.more,
          child: MoreScreen.create(
            locator: locator,
            onTapSetting: () => context.push(MoreRoutePath.setting),
            onTapStatistic: () => context.push(MoreRoutePath.statistic),
            onTapDataStorage: () => context.push(MoreRoutePath.dataStorage),
            onTapDownloadQueue: () => context.push(MoreRoutePath.downloadQueue),
            onTapAbout: () => context.push(MoreRoutePath.aboutUs),
            onTapHelp: () {
              context.showSnackBar(message: '🚧🚧🚧 Under Construction 🚧🚧🚧');
            },
          ),
        );
      },
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
        path: MoreRoutePath.aboutUs,
        name: MoreRoutePath.aboutUs,
        builder: (context, state) => AboutScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.advanced,
        name: MoreRoutePath.advanced,
        builder: (context, state) => AdvancedScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.appearance,
        name: MoreRoutePath.appearance,
        builder: (context, state) => AppearanceScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.dataStorage,
        name: MoreRoutePath.dataStorage,
        builder: (context, state) {
          return DataStorageScreen.create(
            locator: locator,
            onUpdateRootPathConfirmation: () {
              return context.pushNamed<bool>(
                CommonRoutePath.confirmation,
                queryParameters: {
                  CommonRoutePath.confirmationTitle: 'Change Storage Location',
                  CommonRoutePath.confirmationContent:
                      'Your download and backup data will be lost, '
                      'are you sure want to change storage location? ',
                  CommonRoutePath.confirmationNegativeButtonText: 'No',
                  CommonRoutePath.confirmationPositiveButtonText: 'Yes',
                },
              );
            },
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.browse,
        name: MoreRoutePath.browse,
        builder: (context, state) => BrowseScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.downloadQueue,
        name: MoreRoutePath.downloadQueue,
        builder: (context, state) => QueueScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.download,
        name: MoreRoutePath.download,
        builder: (context, state) => DownloadScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.general,
        name: MoreRoutePath.general,
        builder: (context, state) {
          return GeneralScreen.create(
            locator: locator,
            onTapLanguageMenu: (value) {
              return context.push(MoreRoutePath.languagePicker, extra: value);
            },
            onTapCountryMenu: (value) {
              return context.push(MoreRoutePath.countryPicker, extra: value);
            },
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.library,
        name: MoreRoutePath.library,
        builder: (context, state) => LibraryScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.reader,
        name: MoreRoutePath.reader,
        builder: (context, state) => ReaderScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.security,
        name: MoreRoutePath.security,
        builder: (context, state) => SecurityScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.statistic,
        name: MoreRoutePath.statistic,
        builder: (context, state) => StatisticScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.tracking,
        name: MoreRoutePath.tracking,
        builder: (context, state) => TrackingScreen.create(locator: locator),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.setting,
        name: MoreRoutePath.setting,
        builder: (context, state) {
          return SettingScreen.create(
            locator: locator,
            onTapAdvancedMenu: () => context.push(MoreRoutePath.advanced),
            onTapAppearanceMenu: () => context.push(MoreRoutePath.appearance),
            onTapGeneralMenu: () => context.push(MoreRoutePath.general),
            onTapAboutMenu: () => context.push(MoreRoutePath.aboutUs),
            onTapSecurityMenu: () => context.push(MoreRoutePath.security),
            onTapTrackingMenu: () => context.push(MoreRoutePath.tracking),
            onTapBrowseMenu: () => context.push(MoreRoutePath.browse),
            onTapDownloadMenu: () => context.push(MoreRoutePath.download),
            onTapLibraryMenu: () => context.push(MoreRoutePath.library),
            onTapDataStorageMenu: () => context.push(MoreRoutePath.dataStorage),
            onTapReaderMenu: () => context.push(MoreRoutePath.reader),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.languagePicker,
        name: MoreRoutePath.languagePicker,
        pageBuilder: (context, state) {
          return LanguagePickerBottomSheet(
            locator: locator,
            selected: state.extra?.castOrNull(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: MoreRoutePath.countryPicker,
        name: MoreRoutePath.countryPicker,
        pageBuilder: (context, state) {
          return CountryPickerBottomSheet(
            locator: locator,
            selected: state.extra?.castOrNull(),
          );
        },
      ),
    ];
  }
}
