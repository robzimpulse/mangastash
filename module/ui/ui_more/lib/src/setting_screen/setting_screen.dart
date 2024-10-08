import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'setting_screen_cubit.dart';
import 'setting_screen_state.dart';

class SettingScreen extends StatelessWidget {
  final VoidCallback? onTapAdvancedMenu;
  final VoidCallback? onTapAppearanceMenu;

  final VoidCallback? onTapGeneralMenu;
  final VoidCallback? onTapLibraryMenu;
  final VoidCallback? onTapReaderMenu;
  final VoidCallback? onTapDownloadMenu;
  final VoidCallback? onTapTrackingMenu;
  final VoidCallback? onTapBrowseMenu;
  final VoidCallback? onTapManualBackupRestoreMenu;
  final VoidCallback? onTapSecurityMenu;
  final VoidCallback? onTapAboutMenu;

  const SettingScreen({
    super.key,
    this.onTapAdvancedMenu,
    this.onTapAppearanceMenu,
    this.onTapGeneralMenu,
    this.onTapLibraryMenu,
    this.onTapReaderMenu,
    this.onTapDownloadMenu,
    this.onTapTrackingMenu,
    this.onTapBrowseMenu,
    this.onTapManualBackupRestoreMenu,
    this.onTapSecurityMenu,
    this.onTapAboutMenu,
  });

  static Widget create({
    required ServiceLocator locator,
    VoidCallback? onTapAdvancedMenu,
    VoidCallback? onTapAppearanceMenu,
    VoidCallback? onTapGeneralMenu,
    VoidCallback? onTapLibraryMenu,
    VoidCallback? onTapReaderMenu,
    VoidCallback? onTapDownloadMenu,
    VoidCallback? onTapTrackingMenu,
    VoidCallback? onTapBrowseMenu,
    VoidCallback? onTapManualBackupRestoreMenu,
    VoidCallback? onTapSecurityMenu,
    VoidCallback? onTapAboutMenu,
  }) {
    return BlocProvider(
      create: (context) => SettingScreenCubit(
        initialState: const SettingScreenState(),
      ),
      child: SettingScreen(
        onTapAdvancedMenu: onTapAdvancedMenu,
        onTapAppearanceMenu: onTapAppearanceMenu,
        onTapGeneralMenu: onTapGeneralMenu,
        onTapLibraryMenu: onTapLibraryMenu,
        onTapReaderMenu: onTapReaderMenu,
        onTapDownloadMenu: onTapDownloadMenu,
        onTapTrackingMenu: onTapTrackingMenu,
        onTapBrowseMenu: onTapBrowseMenu,
        onTapManualBackupRestoreMenu: onTapManualBackupRestoreMenu,
        onTapSecurityMenu: onTapSecurityMenu,
        onTapAboutMenu: onTapAboutMenu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: const Text('General'),
            subtitle: const Text('App Language, Notifications'),
            onTap: () => onTapGeneralMenu?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Appearance'),
            subtitle: const Text('Theme, Date & Time Format'),
            onTap: () => onTapAppearanceMenu?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.collections_bookmark_outlined),
            title: const Text('Library'),
            subtitle: const Text('Categories, Global Update'),
            onTap: () => onTapLibraryMenu?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.chrome_reader_mode_outlined),
            title: const Text('Reader'),
            subtitle: const Text('Reading Mode, Display, Navigation'),
            onTap: () => onTapReaderMenu?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Downloads'),
            subtitle: const Text('Automatic Download, Download Ahead'),
            onTap: () => onTapDownloadMenu?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.autorenew_outlined),
            title: const Text('Tracking'),
            subtitle: const Text('One-Way Progress Sync, Enhanced Sync'),
            onTap: () => onTapTrackingMenu?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.explore_outlined),
            title: const Text('Browse'),
            subtitle: const Text('Sources, Extensions, Global Search'),
            onTap: () => onTapBrowseMenu?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore_outlined),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Manual & Automatic Backup'),
            onTap: () => onTapManualBackupRestoreMenu?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Security'),
            subtitle: const Text('App Lock, Secure Screen'),
            onTap: () => onTapSecurityMenu?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.code_outlined),
            title: const Text('Advanced'),
            subtitle: const Text('Dump Crash Logs, Battery Optimizations'),
            onTap: () => onTapAdvancedMenu?.call(),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Mangastash Version'),
            onTap: () => onTapAboutMenu?.call(),
          ),
        ],
      ),
    );
  }
}
