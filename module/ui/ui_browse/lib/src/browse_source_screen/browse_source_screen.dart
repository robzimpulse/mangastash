import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_source_screen_cubit.dart';
import 'browse_source_screen_state.dart';

class BrowseSourceScreen extends StatelessWidget {
  const BrowseSourceScreen({
    super.key,
    this.onTapSearchManga,
    this.onTapSource,
    required this.cacheManager,
  });

  final VoidCallback? onTapSearchManga;

  final ValueSetter<Source>? onTapSource;

  final BaseCacheManager cacheManager;

  static Widget create({
    required ServiceLocator locator,
    VoidCallback? onTapSearchManga,
    ValueSetter<Source>? onTapSource,
  }) {
    return BlocProvider(
      create: (context) => BrowseSourceScreenCubit(
        listenSourceUseCase: locator(),
      ),
      child: BrowseSourceScreen(
        onTapSearchManga: onTapSearchManga,
        onTapSource: onTapSource,
        cacheManager: locator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Browse Sources'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.screen_search_desktop_outlined),
            onPressed: () => onTapSearchManga?.call(),
          ),
        ],
      ),
      body: BlocBuilder<BrowseSourceScreenCubit, BrowseSourceScreenState>(
        builder: (context, state) => AdaptivePhysicListView.separated(
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            thickness: 1,
          ),
          itemBuilder: (context, index) => SourceMangaWidget(
            cacheManager: cacheManager,
            iconUrl: state.sources[index].icon ?? '',
            url: state.sources[index].url ?? '',
            name: state.sources[index].name ?? '',
            onTap: () => onTapSource?.call(state.sources[index]),
          ),
          itemCount: state.sources.length,
        ),
      ),
    );
  }
}
