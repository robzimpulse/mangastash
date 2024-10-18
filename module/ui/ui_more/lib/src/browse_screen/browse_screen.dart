import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const BrowseScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Browse Screen'),
      ),
      body: AdaptivePhysicListView(
        children: const [],
      ),
    );
  }
}
