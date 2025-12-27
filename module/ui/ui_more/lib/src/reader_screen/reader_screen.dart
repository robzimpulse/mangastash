import 'package:domain_manga/domain_manga.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key, required this.listenPrefetchChapterConfig});

  final ListenPrefetchChapterConfig listenPrefetchChapterConfig;

  static Widget create({required ServiceLocator locator}) {
    return ReaderScreen(listenPrefetchChapterConfig: locator());
  }

  Widget _buildPrefetchedMenu(BuildContext context) {
    return MultiSliver(
      pushPinnedChildren: true,
      children: [
        SliverPinnedHeader(
          child: Container(
            color: Theme.of(context).cardColor,
            child: ListTile(
              title: const Text('Prefetch Chapter'),
              subtitle: const Text(
                'How many chapter should be fetched around current chapter',
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: const Text('Previous Chapter'),
            trailing: SizedBox(
              width: 56,
              child: StreamBuilder(
                stream: listenPrefetchChapterConfig.numOfPrefetchedPrevChapter,
                builder: (context, snapshot) {
                  return DropdownButton(
                    value: snapshot.data,
                    items: List.generate(
                      6,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text('$index'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value == null) return;
                      listenPrefetchChapterConfig
                          .updateNumOfPrefetchedPrevChapter(value: value);
                    },
                  );
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListTile(
            title: const Text('Next Chapter'),
            trailing: SizedBox(
              width: 56,
              child: StreamBuilder(
                stream: listenPrefetchChapterConfig.numOfPrefetchedNextChapter,
                builder: (context, snapshot) {
                  return DropdownButton(
                    value: snapshot.data,
                    items: List.generate(
                      6,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text('$index'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value == null) return;
                      listenPrefetchChapterConfig
                          .updateNumOfPrefetchedNextChapter(value: value);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(title: const Text('Reader Screen')),
      body: CustomScrollView(slivers: [_buildPrefetchedMenu(context)]),
    );
  }
}
