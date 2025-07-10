import 'package:entity_manga/entity_manga.dart';
import 'package:ui_common/ui_common.dart';

class ChapterDescriptionWidget extends StatelessWidget {
  const ChapterDescriptionWidget({
    super.key,
    this.tags = const [],
    this.description,
    this.absorber,
    this.isLoading = true,
    this.onTapTag,
  });

  final List<Tag> tags;

  final String? description;

  final SliverOverlapAbsorberHandle? absorber;

  final bool isLoading;

  final ValueSetter<Tag>? onTapTag;

  @override
  Widget build(BuildContext context) {
    final absorber = this.absorber;

    return CustomScrollView(
      slivers: [
        if (absorber != null) SliverOverlapInjector(handle: absorber),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: MultiSliver(
            children: [
              SliverToBoxAdapter(
                child: Text(
                  'Tags',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: (tags.isEmpty && !isLoading)
                    ? const SizedBox(
                        height: 150,
                        child: Center(
                          child: Text('No Data'),
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (isLoading) ...[
                            for (final _ in List.generate(8, (e) => e))
                              ShimmerLoading.multiline(
                                isLoading: isLoading,
                                width: 50,
                                height: 30,
                                lines: 1,
                              ),
                          ] else ...[
                            for (final tag in tags)
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 30,
                                ),
                                child: OutlinedButton(
                                  child: Text(tag.name ?? ''),
                                  onPressed: () => onTapTag?.call(tag),
                                ),
                              ),
                          ],
                        ],
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: ShimmerLoading.multiline(
                  isLoading: isLoading,
                  width: double.infinity,
                  height: 15,
                  lines: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(description ?? ''),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
