import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

import 'base/icon_with_text_widget.dart';

class ChapterTileWidget extends StatelessWidget {
  const ChapterTileWidget({
    super.key,
    this.onTap,
    this.padding = EdgeInsets.zero,
    this.title,
    this.language,
    this.uploadedAt,
    this.groups,
    this.isPrefetching = false,
    this.lastReadAt,
    this.opacity = 1,
    this.onTapLongPress,
    this.cacheManager,
    this.mangaTitle,
    this.sourceIconUrl,
    this.coverUrl,
  });

  factory ChapterTileWidget.chapter({
    Manga? manga,
    required Chapter chapter,
    Key? key,
    VoidCallback? onTap,
    VoidCallback? onTapLongPress,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double opacity = 1,
    bool isPrefetching = false,
    DateTime? lastReadAt,
    BaseCacheManager? cacheManager,
  }) {
    return ChapterTileWidget(
      key: key,
      mangaTitle: manga?.title,
      coverUrl: manga?.coverUrl,
      sourceIconUrl: manga?.source?.let(SourceEnum.fromName)?.icon,
      title: ['Chapter ${chapter.chapter}', chapter.title].nonNulls.join(' - '),
      language: Language.fromCode(chapter.translatedLanguage),
      uploadedAt: chapter.readableAt,
      groups: chapter.scanlationGroup,
      onTap: onTap,
      onTapLongPress: onTapLongPress,
      padding: padding,
      opacity: opacity,
      isPrefetching: isPrefetching,
      lastReadAt: lastReadAt,
      cacheManager: cacheManager,
    );
  }

  final VoidCallback? onTap;
  final VoidCallback? onTapLongPress;
  final EdgeInsetsGeometry padding;
  final String? title;
  final String? groups;
  final Language? language;
  final DateTime? uploadedAt;
  final DateTime? lastReadAt;
  final bool isPrefetching;
  final double opacity;
  final String? sourceIconUrl;
  final String? mangaTitle;
  final String? coverUrl;
  final BaseCacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    final coverUrl = this.coverUrl;
    final mangaTitle = this.mangaTitle;
    final sourceIconUrl = this.sourceIconUrl;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onTapLongPress,
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (coverUrl != null) ...[
                  CachedNetworkImage(
                    fit: BoxFit.cover,
                    cacheManager: cacheManager,
                    imageUrl: coverUrl,
                    width: 84,
                    errorWidget: (context, url, error) {
                      return const Center(child: Icon(Icons.error));
                    },
                    progressIndicatorBuilder: (context, url, progress) {
                      return Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children:
                        <Widget>[
                          if (mangaTitle != null)
                            Text(
                              mangaTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          IconWithTextWidget(
                            icon: language?.flag(width: 20, height: 10),
                            text: Expanded(
                              child: Text(
                                title ?? ' - ',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconWithTextWidget(
                            icon: const Icon(Icons.people, size: 20),
                            text: Text(groups ?? ' - '),
                          ),
                          IconWithTextWidget(
                            icon: const Icon(Icons.access_time, size: 20),
                            text: Text(uploadedAt?.readableFormat ?? ' - '),
                          ),
                          if (lastReadAt != null)
                            IconWithTextWidget(
                              icon: const Icon(
                                Icons.menu_book_outlined,
                                size: 20,
                              ),
                              text: Text(lastReadAt?.readableFormat ?? '-'),
                            ),
                        ].intersperse(const SizedBox(height: 4)).toList(),
                  ),
                ),
                if (isPrefetching)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (sourceIconUrl != null)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CachedNetworkImage(
                        cacheManager: cacheManager,
                        imageUrl: sourceIconUrl,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) {
                          return const Center(child: Icon(Icons.error));
                        },
                        progressIndicatorBuilder: (context, url, progress) {
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
