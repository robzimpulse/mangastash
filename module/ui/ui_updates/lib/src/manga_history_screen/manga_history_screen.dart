import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_history_screen_cubit.dart';
import 'manga_history_screen_state.dart';

class MangaHistoryScreen extends StatelessWidget {
  const MangaHistoryScreen({super.key});

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => MangaHistoryScreenCubit(
        initialState: MangaHistoryScreenState(),
      )..init(),
      child: const MangaHistoryScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Histories'),
      ),
      body: const Center(
        child: Text('🚧🚧🚧 Under Construction 🚧🚧🚧'),
      ),
    );
  }
}