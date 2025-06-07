import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
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

  Widget _manga({required BuildContext context, required Manga value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: MangaShelfItem(
        title: value.title ?? '',
        coverUrl: value.coverUrl ?? '',
        layout: MangaShelfItemLayout.list,
        cacheManager: cacheManager,
      ),
    );
  }

  Widget _chapter({required BuildContext context, required Chapter value}) {
    return MangaChapterTileWidget(
      padding: const EdgeInsets.all(8),
      title: ['Chapter ${value.chapter}', value.title].nonNulls.join(' - '),
      language: Language.fromCode(value.translatedLanguage),
      uploadedAt: value.lastReadAt,
      groups: value.scanlationGroup,
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
                pushPinnedChildren: true,
                children: [
                  SliverPinnedHeader(
                    child: _manga(context: context, value: history.key),
                  ),
                  for (final item in history.value)
                    SliverToBoxAdapter(
                      child: _chapter(context: context, value: item),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
