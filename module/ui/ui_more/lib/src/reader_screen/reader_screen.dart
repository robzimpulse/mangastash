import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const ReaderScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Reader Screen'),
      ),
      body: AdaptivePhysicListView(
        children: const [],
      ),
    );
  }
}
