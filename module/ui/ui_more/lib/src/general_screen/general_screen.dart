import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class GeneralScreen extends StatelessWidget {
  const GeneralScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const GeneralScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('General Screen'),
      ),
      body: ListView(
        children: const [],
      ),
    );
  }
}
