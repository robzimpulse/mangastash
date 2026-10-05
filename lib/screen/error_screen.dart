import 'package:core_route/core_route.dart';
import 'package:ui_common/ui_common.dart';

import '../main_path.dart';

/// Not-found / error page. The back button must survive being the only
/// page on the navigator stack (restored deep link, `onException` `go`):
/// it pops when possible and otherwise returns to the home location
/// instead of throwing "there is nothing to pop" (issue #130).
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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(MainPath.main);
            }
          },
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
