import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

import 'shimmer_loading_widget.dart';

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
    this.isLoading = false,
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

  final double horizontalPadding;

  final Widget separator;

  final bool isLoading;

  Widget _header() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            ShimmerLoading.box(
              isLoading: isLoading,
              width: 100,
              height: 150,
              child: CachedNetworkImage(
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
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ShimmerLoading.multiline(
                isLoading: isLoading,
                width: double.infinity,
                height: 15,
                lines: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (title != null) Text(title ?? ''),
                    if (author != null) Text(author ?? ''),
                    if (status != null) Text(status ?? ''),
                  ].intersperse(const SizedBox(height: 4)).toList(),
                ),
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
            ShimmerLoading.box(
              isLoading: isLoading,
              width: 50,
              height: 50,
              child: IconButton(
                icon: const Icon(Icons.favorite_outline),
                onPressed: onTapFavorite,
              ),
            ),
            const SizedBox.shrink(),
            ShimmerLoading.box(
              isLoading: isLoading,
              width: 50,
              height: 50,
              child: IconButton(
                icon: const Icon(Icons.web),
                onPressed: onTapWebsite,
              ),
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
        child: ShimmerLoading.multiline(
          isLoading: isLoading,
          width: double.infinity,
          height: 15,
          lines: 3,
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
                        const Icon(Icons.keyboard_arrow_down),
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
      ),
    );
  }

  Widget _loadingTags() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...List.generate(
              10,
              (index) => ShimmerLoading.box(
                isLoading: isLoading,
                width: 80,
                height: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _loadedTags() {
    final data = tags;
    if (data == null) return null;
    if (data.isEmpty) return null;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in data)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 30),
                child: OutlinedButton(
                  child: Text(item),
                  onPressed: () => onTapTag?.call(item),
                ),
              ),
          ],
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
      isLoading ? _loadingTags() : _loadedTags(),
      ...child,
    ].whereType<Widget>().intersperse(_separator());

    return CustomScrollView(slivers: [_separator(), ...widgets]);
  }
}
