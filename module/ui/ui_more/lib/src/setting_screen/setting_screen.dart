import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'setting_screen_cubit.dart';
import 'setting_screen_state.dart';

class SettingScreen extends StatelessWidget {

  final VoidCallback? onTapAdvancedMenu;

  const SettingScreen({
    super.key,
    this.onTapAdvancedMenu,
  });

  static Widget create({
    required ServiceLocator locator,
    VoidCallback? onTapAdvancedMenu,
  }) {
    return BlocProvider(
      create: (context) => SettingScreenCubit(
        initialState: const SettingScreenState(),
      ),
      child: SettingScreen(
        onTapAdvancedMenu: onTapAdvancedMenu,
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
            title: const Text('General'),
            subtitle: const Text('App Language, Notifications'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Appearance'),
            subtitle: const Text('Theme, Date & Time Format'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Library'),
            subtitle: const Text('Categories, Global Update'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Downloads'),
            subtitle: const Text('Automatic Download, Download Ahead'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Tracking'),
            subtitle: const Text('One-Way Progress Sync, Enhanced Sync'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Browse'),
            subtitle: const Text('Sources, Extensions, Global Search'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Backup & Restore'),
            subtitle: const Text('Manual & Automatic Backup'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Security'),
            subtitle: const Text('App Lock, Secure Screen'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Advanced'),
            subtitle: const Text('Dump Crash Logs, Battery Optimizations'),
            onTap: () => onTapAdvancedMenu?.call(),
          ),
          ListTile(
            title: const Text('About'),
            subtitle: const Text('Mangastash Version'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
