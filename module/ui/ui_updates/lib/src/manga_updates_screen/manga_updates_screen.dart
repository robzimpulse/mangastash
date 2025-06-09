import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_updates_screen_cubit.dart';
import 'manga_updates_screen_state.dart';

class MangaUpdatesScreen extends StatelessWidget {
  const MangaUpdatesScreen({super.key});

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => MangaUpdatesScreenCubit()..init(),
      child: const MangaUpdatesScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Manga Updates'),
        actions: [
          IconButton(
            onPressed: () => context.showSnackBar(
              message: '🚧🚧🚧 Under Construction 🚧🚧🚧',
            ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: const Center(
        child: Text('🚧🚧🚧 Under Construction 🚧🚧🚧'),
      ),
    );
  }
}
