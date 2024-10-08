import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const AppearanceScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Appearance Screen'),
      ),
      body: ListView(
        children: const [],
      ),
    );
  }
}
