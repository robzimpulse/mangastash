import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_source_cubit.dart';
import 'browse_source_state.dart';

class BrowseSourceScreen extends StatelessWidget {
  const BrowseSourceScreen({
    super.key,
    required this.onTapSearchManga,
    required this.onTapSource,
  });

  final Function(BuildContext) onTapSearchManga;

  final Function(BuildContext, MangaSource) onTapSource;

  static Widget create({
    required ServiceLocator locator,
    required Function(BuildContext) onTapSearchManga,
    required Function(BuildContext, MangaSource) onTapSource,
  }) {
    return BlocProvider(
      create: (context) => BrowseSourceCubit(
        getAllMangaSourcesUseCase: locator(),
      )..init(),
      child: BrowseSourceScreen(
        onTapSearchManga: onTapSearchManga,
        onTapSource: onTapSource,
      ),
    );
  }

  BrowseSourceCubit _cubit(BuildContext context) {
    return context.read();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Browse Sources'),
        actions: [
          IconButton(
            icon: const Icon(Icons.screen_search_desktop_outlined),
            onPressed: () => onTapSearchManga.call(context),
          ),
        ],
      ),
      body: BlocBuilder<BrowseSourceCubit, BrowseSourceState>(
        builder: (context, state) => RefreshIndicator(
          onRefresh: () => _cubit(context).init(),
          child: AdaptivePhysicListView.separated(
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 1,
            ),
            itemBuilder: (context, index) => state.isLoading
                ? const SourceMangaWidget.shimmer()
                : SourceMangaWidget(
                    iconUrl: state.sources[index].iconUrl ?? '',
                    url: state.sources[index].url ?? '',
                    name: state.sources[index].name ?? '',
                    onTap: () => onTapSource.call(
                      context,
                      state.sources[index],
                    ),
                  ),
            itemCount: state.isLoading ? 100 : state.sources.length,
          ),
        ),
      ),
    );
  }
}
