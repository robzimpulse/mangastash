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
    this.onTapAddToLibrary,
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

  final void Function()? onTapAddToLibrary;

  final void Function()? onTapWebsite;

  final void Function(String)? onTapTag;

  final List<Widget> child;

  final double horizontalPadding;

  final Widget separator;

  final bool isLoading;

  Widget _header(BuildContext context) {
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
                    if (title != null)
                      Text(
                        title ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    if (author != null)
                      Text(
                        author ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (status != null)
                      Text(
                        status ?? '',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ].intersperse(const SizedBox(height: 4)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: onTapAddToLibrary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerLoading.box(
                    isLoading: isLoading,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.favorite_outline),
                  ),
                  const SizedBox(height: 2),
                  ShimmerLoading.multiline(
                    isLoading: isLoading,
                    lines: 1,
                    width: 50,
                    height: 15,
                    child: const Text('Add to Library'),
                  ),
                ],
              ),
            ),
            const SizedBox.shrink(),
            InkWell(
              onTap: onTapWebsite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerLoading.box(
                    isLoading: isLoading,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.web),
                  ),
                  const SizedBox(height: 2),
                  ShimmerLoading.multiline(
                    isLoading: isLoading,
                    lines: 1,
                    width: 50,
                    height: 15,
                    child: const Text('Website'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _description(BuildContext context) {
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

  Widget _loadingTags(BuildContext context) {
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

  Widget? _loadedTags(BuildContext context) {
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

  Widget _separator(BuildContext context) {
    return SliverToBoxAdapter(
      child: separator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final widgets = [
      _header(context),
      _buttons(context),
      _description(context),
      isLoading ? _loadingTags(context) : _loadedTags(context),
      ...child,
    ].whereType<Widget>().intersperse(_separator(context));

    return CustomScrollView(slivers: [_separator(context), ...widgets]);
  }
}
