import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_source_cubit.dart';
import 'browse_source_state.dart';

class BrowseSourceScreen extends StatelessWidget {
  const BrowseSourceScreen({
    super.key,
    this.onTapSearchManga,
    this.onTapSource,
  });

  final Function()? onTapSearchManga;

  final Function(MangaSource)? onTapSource;

  static Widget create({
    required ServiceLocator locator,
    Function()? onTapSearchManga,
    Function(MangaSource)? onTapSource,
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
            onPressed: () => onTapSearchManga?.call(),
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
                    name: state.sources[index].name?.value ?? '',
                    onTap: () => onTapSource?.call(state.sources[index]),
                  ),
            itemCount: state.isLoading ? 100 : state.sources.length,
          ),
        ),
      ),
    );
  }
}
