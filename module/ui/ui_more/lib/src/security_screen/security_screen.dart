import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const SecurityScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Security Screen'),
      ),
      body: AdaptivePhysicListView(
        children: const [],
      ),
    );
  }
}
