import 'package:core_storage/core_storage.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
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
    required this.imagesCacheManager,
  });

  final VoidCallback? onTapSearchManga;

  final ValueSetter<SourceExternal>? onTapSource;

  final ImagesCacheManager imagesCacheManager;

  static Widget create({
    required ServiceLocator locator,
    VoidCallback? onTapSearchManga,
    ValueSetter<SourceExternal>? onTapSource,
  }) {
    return BlocProvider(
      create: (context) {
        return BrowseSourceScreenCubit(
          listenSourceUseCase: locator(),
          updateSourceUseCase: locator(),
          customSourceDao: locator(),
        );
      },
      child: BrowseSourceScreen(
        onTapSearchManga: onTapSearchManga,
        onTapSource: onTapSource,
        imagesCacheManager: locator(),
      ),
    );
  }

  /// **Purpose:**
  /// Presents a dialog to side-load a custom manga source script.
  /// 
  /// **Usage:**
  /// Called when the user taps the floating action button. Submitting a URL 
  /// triggers [BrowseSourceScreenCubit.addCustomSource].
  void _showAddSourceDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Custom Source'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter script URL',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final url = controller.text;
                if (url.isNotEmpty) {
                  context.read<BrowseSourceScreenCubit>().addCustomSource(url);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSourceDialog(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<BrowseSourceScreenCubit, BrowseSourceScreenState>(
        builder: (context, state) {
          return AdaptivePhysicListView.separated(
            separatorBuilder: (context, index) {
              return const Divider(height: 1, thickness: 1);
            },
            itemBuilder: (context, index) {
              return SourceTileWidget(
                cacheManager: imagesCacheManager,
                iconUrl: state.sources[index].iconUrl,
                url: state.sources[index].baseUrl,
                name: state.sources[index].name,
                onTap: () => onTapSource?.call(state.sources[index]),
              );
            },
            itemCount: state.sources.length,
          );
        },
      ),
    );
  }
}
