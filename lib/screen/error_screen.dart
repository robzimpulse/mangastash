import 'package:core_route/core_route.dart';
import 'package:ui_common/ui_common.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // TODO: beautify error screen
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Error Screen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
