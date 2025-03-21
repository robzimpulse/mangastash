import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const AboutScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('About Screen'),
      ),
      body: AdaptivePhysicListView(
        children: const [],
      ),
    );
  }
}
