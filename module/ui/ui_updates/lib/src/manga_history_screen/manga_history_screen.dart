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
        initialState: const MangaHistoryScreenState(),
        listenReadHistoryUseCase: locator(),
      )..init(),
      child: const MangaHistoryScreen(),
    );
  }

  MangaHistoryScreenCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<MangaHistoryScreenState> builder,
    BlocBuilderCondition<MangaHistoryScreenState>? buildWhen,
  }) {
    return BlocBuilder<MangaHistoryScreenCubit, MangaHistoryScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Histories'),
      ),
      body: _builder(
        builder: (context, state) => ListView.builder(
          itemBuilder: (context, index) => ListTile(
            title: Text(state.histories[index].manga?.title ?? ''),
          ),
          itemCount: state.histories.length,
        ),
      ),
    );
  }
}
