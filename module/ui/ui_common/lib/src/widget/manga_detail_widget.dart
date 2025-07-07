import 'package:core_storage/core_storage.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'base/shimmer_loading_widget.dart';

class MangaDetailWidget extends StatelessWidget {
  const MangaDetailWidget({
    super.key,
    this.description,
    this.onTapAddToLibrary,
    this.onTapPrefetch,
    this.onTapWebsite,
    this.tags = const [],
    this.onTapTag,
    this.horizontalPadding = 8,
    this.separator = const SizedBox(height: 8),
    this.isLoadingManga = false,
    this.isLoadingChapters = false,
    this.isOnLibrary = false,
    this.cacheManager,
  });

  final String? description;

  final List<String> tags;

  final void Function()? onTapPrefetch;

  final void Function()? onTapAddToLibrary;

  final void Function()? onTapWebsite;

  final void Function(String)? onTapTag;

  final double horizontalPadding;

  final Widget separator;

  final bool isLoadingManga;

  final bool isLoadingChapters;

  final bool isOnLibrary;

  final BaseCacheManager? cacheManager;

  Widget _buttons(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              onTap: onTapAddToLibrary,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerLoading.box(
                    isLoading: isLoadingManga,
                    width: 50,
                    height: 50,
                    child: Icon(
                      isOnLibrary ? Icons.favorite : Icons.favorite_outline,
                    ),
                  ),
                  const SizedBox(height: 2),
                  ShimmerLoading.multiline(
                    isLoading: isLoadingManga,
                    lines: 1,
                    width: 50,
                    height: 15,
                    child: const Text('Library'),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onTapPrefetch,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerLoading.box(
                    isLoading: isLoadingManga && isLoadingChapters,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.cloud_download),
                  ),
                  const SizedBox(height: 2),
                  ShimmerLoading.multiline(
                    isLoading: isLoadingManga && isLoadingChapters,
                    lines: 1,
                    width: 50,
                    height: 15,
                    child: const Text('Prefetch'),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onTapWebsite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShimmerLoading.box(
                    isLoading: isLoadingManga,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.web),
                  ),
                  const SizedBox(height: 2),
                  ShimmerLoading.multiline(
                    isLoading: isLoadingManga,
                    lines: 1,
                    width: 50,
                    height: 15,
                    child: const Text('Website'),
                  ),
                ],
              ),
            ),
          ].intersperse(const SizedBox.shrink()).toList(),
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
          isLoading: isLoadingManga,
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
                isLoading: isLoadingManga,
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
    if (tags.isEmpty) return null;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverToBoxAdapter(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in tags)
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
      _buttons(context),
      _description(context),
      isLoadingManga ? _loadingTags(context) : _loadedTags(context),
    ].whereType<Widget>().intersperse(_separator(context));

    return MultiSliver(children: [_separator(context), ...widgets]);
  }
}
