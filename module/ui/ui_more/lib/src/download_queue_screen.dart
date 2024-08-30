import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class DownloadQueueScreen extends StatelessWidget {
  const DownloadQueueScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const DownloadQueueScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Download Queue'),
      ),
      body: ListView(
        children: const [],
      ),
    );
  }
}
