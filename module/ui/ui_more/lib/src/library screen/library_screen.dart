import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return const LibraryScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Library Screen'),
      ),
      body: ListView(
        children: const [],
      ),
    );
  }
}
