import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class AdvancedScreen extends StatelessWidget {
  const AdvancedScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const AdvancedScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Advanced Screen'),
      ),
      body: ListView(
        children: const [],
      ),
    );
  }
}
