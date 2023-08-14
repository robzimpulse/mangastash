import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class MoreScreen extends StatelessWidget {
  final Function(BuildContext) onTapSetting;

  final Function(BuildContext) onTapStatistic;

  final Function(BuildContext) onTapBackupRestore;

  final Function(BuildContext) onTapDownloadQueue;

  const MoreScreen({
    super.key,
    required this.onTapSetting,
    required this.onTapStatistic,
    required this.onTapBackupRestore,
    required this.onTapDownloadQueue,
  });

  static Widget create({
    required ServiceLocator locator,
    required Function(BuildContext) onTapSetting,
    required Function(BuildContext) onTapStatistic,
    required Function(BuildContext) onTapBackupRestore,
    required Function(BuildContext) onTapDownloadQueue,
  }) {
    return MoreScreen(
      onTapSetting: onTapSetting,
      onTapStatistic: onTapStatistic,
      onTapBackupRestore: onTapBackupRestore,
      onTapDownloadQueue: onTapDownloadQueue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
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
                  onChanged: (value) {},
                  secondary: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.cloud_off),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Incognito Mode'),
                  subtitle: const Text('Pause reading history'),
                  value: true,
                  onChanged: (value) {},
                  secondary: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.disabled_visible),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                ListTile(
                  title: const Text('Download Queue'),
                  subtitle: const Text('22 remaining'),
                  onTap: () => onTapDownloadQueue.call(context),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.download),
                  ),
                ),
                ListTile(
                  title: const Text('Statistic'),
                  onTap: () => onTapStatistic.call(context),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.auto_graph),
                  ),
                ),
                ListTile(
                  title: const Text('Backup and Restore'),
                  onTap: () => onTapBackupRestore.call(context),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.settings_backup_restore),
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                ListTile(
                  title: const Text('Settings'),
                  onTap: () => onTapSetting.call(context),
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.settings),
                  ),
                ),
                ListTile(
                  title: const Text('About'),
                  onTap: () {},
                  leading: const SizedBox(
                    height: double.infinity,
                    child: Icon(Icons.info_outline),
                  ),
                ),
                ListTile(
                  title: const Text('Help'),
                  onTap: () {},
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
