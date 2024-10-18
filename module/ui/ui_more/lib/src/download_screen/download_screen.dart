import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const DownloadScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Download Screen'),
      ),
      body: AdaptivePhysicListView(
        children: const [],
      ),
    );
  }
}
