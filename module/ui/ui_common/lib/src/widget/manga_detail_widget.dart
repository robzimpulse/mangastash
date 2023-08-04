import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class MangaDetailWidget extends StatelessWidget {
  const MangaDetailWidget({
    super.key,
    this.coverUrl,
    this.title,
    this.author,
    this.status,
    this.description,
  });

  final String? coverUrl;

  final String? title;

  final String? author;

  final String? status;

  final String? description;

  Widget _header() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: coverUrl ?? '',
              width: 100,
              height: 150,
              errorWidget: (context, url, error) => const Icon(Icons.error),
              progressIndicatorBuilder: (context, url, downloadProgress) {
                return Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
                );
              },
            ),
            Column(
              children: [
                if (title != null) Text(title ?? ''),
                if (author != null) Text(author ?? ''),
                if (status != null) Text(status ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttons() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite_outline),
              onPressed: () {},
            ),
            const SizedBox.shrink(),
            IconButton(
              icon: const Icon(Icons.web),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _description() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverToBoxAdapter(
        child: ExpandableNotifier(
          child: ExpandablePanel(
            theme: const ExpandableThemeData(
              tapBodyToExpand: true,
              tapBodyToCollapse: true,
            ),
            collapsed: Column(
              children: [
                Text(description ?? '', maxLines: 3),
                const Icon(Icons.keyboard_arrow_down)
              ],
            ),
            expanded: Column(
              children: [
                Text(description ?? ''),
                const Icon(Icons.keyboard_arrow_up),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tags() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 32,
          child: Center(
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => OutlinedButton(
                child: Text('Index $index'),
                onPressed: () {},
              ),
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: 100,
            ),
          ),
        ),
      ),
    );
  }

  Widget _chapterCount() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: const [
            Text('319 Chapters'),
          ],
        ),
      ),
    );
  }

  Widget _chapters() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Text('Chapter $index'),
          childCount: 319,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _header(),
        _buttons(),
        if (description != null) _description(),
        _tags(),
        _chapterCount(),
        _chapters(),
      ],
    );
  }
}
