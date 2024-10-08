import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class MoreScreen extends StatelessWidget {
  final VoidCallback? onTapSetting;
  final VoidCallback? onTapStatistic;
  final VoidCallback? onTapBackupRestore;
  final VoidCallback? onTapDownloadQueue;
  final VoidCallback? onTapAbout;


  const MoreScreen({
    super.key,
    this.onTapSetting,
    this.onTapStatistic,
    this.onTapBackupRestore,
    this.onTapDownloadQueue,
    this.onTapAbout,
  });

  static Widget create({
    required ServiceLocator locator,
    VoidCallback? onTapSetting,
    VoidCallback? onTapStatistic,
    VoidCallback? onTapBackupRestore,
    VoidCallback? onTapDownloadQueue,
    VoidCallback? onTapAbout,
  }) {
    return MoreScreen(
      onTapSetting: onTapSetting,
      onTapStatistic: onTapStatistic,
      onTapBackupRestore: onTapBackupRestore,
      onTapDownloadQueue: onTapDownloadQueue,
      onTapAbout: onTapAbout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      body: Column(
        children: [
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Manga Stash',
                style: TextStyle(fontSize: 56),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: AdaptivePhysicListView(
              padding: EdgeInsets.zero,
              children: [
                SwitchListTile(
                  title: const Text('Downloaded Only'),
                  subtitle: const Text('Filters all entries in your library'),
                  value: true,
                  // TODO: implement this
                  onChanged: (value) => context.showSnackBar(
                    message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
                  ),
                  secondary: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.cloud_off),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Incognito Mode'),
                  subtitle: const Text('Pause reading history'),
                  value: true,
                  // TODO: implement this
                  onChanged: (value) => context.showSnackBar(
                    message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
                  ),
                  secondary: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.disabled_visible),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                ListTile(
                  title: const Text('Download Queue'),
                  subtitle: const Text('22 remaining'),
                  onTap: () => onTapDownloadQueue?.call(),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.download),
                  ),
                ),
                ListTile(
                  title: const Text('Statistic'),
                  onTap: () => onTapStatistic?.call(),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.auto_graph),
                  ),
                ),
                ListTile(
                  title: const Text('Backup and Restore'),
                  onTap: () => onTapBackupRestore?.call(),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.settings_backup_restore),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                ListTile(
                  title: const Text('Settings'),
                  onTap: () => onTapSetting?.call(),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.settings),
                  ),
                ),
                ListTile(
                  title: const Text('About'),
                  // TODO: implement this
                  onTap: () => onTapAbout?.call(),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.info_outline),
                  ),
                ),
                ListTile(
                  title: const Text('Help'),
                  // TODO: implement this
                  onTap: () => context.showSnackBar(
                    message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
                  ),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.help_outline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
