import 'package:core_storage/core_storage.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_history_screen_cubit.dart';
import 'manga_history_screen_state.dart';

class MangaHistoryScreen extends StatelessWidget {
  const MangaHistoryScreen({super.key, required this.cacheManager});

  final BaseCacheManager cacheManager;

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => MangaHistoryScreenCubit(
        initialState: const MangaHistoryScreenState(),
        listenReadHistoryUseCase: locator(),
      )..init(),
      child: MangaHistoryScreen(
        cacheManager: locator(),
      ),
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
        builder: (context, state) => CustomScrollView(
          slivers: [
            for (final history in state.histories.entries)
              MultiSliver(
                children: [
                  SliverPinnedHeader(
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: MangaShelfItem(
                        title: history.key.title ?? '',
                        coverUrl: history.key.coverUrl ?? '',
                        layout: MangaShelfItemLayout.list,
                        cacheManager: cacheManager,
                      ),
                    ),
                  ),
                  for (final item in history.value)
                    SliverToBoxAdapter(
                      child: ListTile(
                        title: Text(item.title ?? ''),
                        subtitle: Text(item.chapter ?? ''),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
