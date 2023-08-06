import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../ui_common.dart';

class MangaDetailWidget extends StatelessWidget {
  const MangaDetailWidget({
    super.key,
    this.coverUrl,
    this.title,
    this.author,
    this.status,
    this.description,
    this.onTapFavorite,
    this.onTapWebsite,
    this.tags,
    this.onTapTag,
    required this.child,
  });

  final String? coverUrl;

  final String? title;

  final String? author;

  final String? status;

  final String? description;

  final List<String>? tags;

  final void Function()? onTapFavorite;

  final void Function()? onTapWebsite;

  final void Function(String)? onTapTag;

  final List<Widget> child;

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
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (title != null) Text(title ?? ''),
                  if (author != null) Text(author ?? ''),
                  if (status != null) Text(status ?? ''),
                ].intersperse(const SizedBox(height: 4)).toList(),
              ),
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
              onPressed: onTapFavorite,
            ),
            const SizedBox.shrink(),
            IconButton(
              icon: const Icon(Icons.web),
              onPressed: onTapWebsite,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _description() {
    final text = description;
    if (text == null) return null;
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
                Text(text, maxLines: 3),
                const Icon(Icons.keyboard_arrow_down)
              ],
            ),
            expanded: Column(
              children: [
                Text(text),
                const Icon(Icons.keyboard_arrow_up),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _tags() {
    final data = tags;
    if (data == null) return null;
    if (data.isEmpty) return null;
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
                child: Text(data[index]),
                onPressed: () => onTapTag?.call(data[index]),
              ),
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: data.length,
            ),
          ),
        ),
      ),
    );
  }

  // List<Widget>? _chapters() {
  //   if (isLoading) {
  //     return [
  //       const SliverFillRemaining(
  //         hasScrollBody: false,
  //         child: Center(
  //           child: CircularProgressIndicator(),
  //         ),
  //       ),
  //     ];
  //   }
  //
  //   final count = chapterCount;
  //   if (count == null) return null;
  //   if (count < 1) return null;
  //
  //   return [
  //     SliverPadding(
  //       padding: const EdgeInsets.symmetric(horizontal: 8),
  //       sliver: SliverToBoxAdapter(
  //         child: Row(
  //           children: [
  //             Text('$count Chapters'),
  //           ],
  //         ),
  //       ),
  //     ),
  //     SliverPadding(
  //       padding: const EdgeInsets.symmetric(horizontal: 8),
  //       sliver: SliverList(
  //         delegate: SliverChildBuilderDelegate(
  //           (context, index) => ListTile(
  //             title: Text('Chapter $index'),
  //             onTap: () => onTapChapterIndex?.call(index),
  //           ),
  //           childCount: count,
  //         ),
  //       ),
  //     )
  //   ];
  // }

  Widget _separator() {
    return const SliverToBoxAdapter(
      child: SizedBox(height: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _header(),
        _buttons(),
        _description(),
        _tags(),
        ...child,
      ].whereType<Widget>().intersperseOuter(_separator()).toList(),
    );
  }
}
