import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

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
    this.horizontalPadding = 8,
    this.separator = const SizedBox(height: 8),
    required this.child,
  });

  MangaDetailWidget.loading({
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
    this.horizontalPadding = 8,
    this.separator = const SizedBox(height: 8),
  }) : child = [
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ];

  MangaDetailWidget.message({
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
    this.horizontalPadding = 8,
    this.separator = const SizedBox(height: 8),
    required String message,
  }) : child = [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ];

  MangaDetailWidget.content({
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
    this.horizontalPadding = 8,
    this.separator = const SizedBox(height: 8),
    required int chapterCount,
    required NullableIndexedWidgetBuilder chapterForIndex,
  }) : child = [
          SliverToBoxAdapter(
            child: ListTile(
              title: Text('$chapterCount Chapters'),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              chapterForIndex,
              childCount: chapterCount,
            ),
          ),
        ];

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

  final double horizontalPadding;

  final Widget separator;

  Widget _header() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: ExpandableNotifier(
          child: ExpandablePanel(
            theme: const ExpandableThemeData(
              tapBodyToExpand: true,
              tapBodyToCollapse: true,
            ),
            collapsed: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(text, maxLines: 3),
                      const Icon(Icons.keyboard_arrow_down)
                    ],
                  ),
                ),
              ],
            ),
            expanded: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(text),
                      const Icon(Icons.keyboard_arrow_up),
                    ],
                  ),
                ),
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
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 32,
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
    );
  }

  Widget _separator() => SliverToBoxAdapter(child: separator);

  @override
  Widget build(BuildContext context) {
    final widgets = [
      _header(),
      _buttons(),
      _description(),
      _tags(),
    ].whereType<Widget>().intersperse(_separator());

    return CustomScrollView(slivers: [_separator(), ...widgets, ...child]);
  }
}
