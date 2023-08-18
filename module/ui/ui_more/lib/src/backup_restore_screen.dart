import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const BackupRestoreScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: const Text('Backup and Restore'),
      ),
      body: ListView(
        children: [],
      ),
    );
  }
}
