import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const TrackingScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Tracking Screen'),
      ),
      body: ListView(
        children: const [],
      ),
    );
  }
}
