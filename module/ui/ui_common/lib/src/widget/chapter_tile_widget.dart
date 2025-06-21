import 'package:core_environment/core_environment.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

import 'icon_with_text_widget.dart';

class ChapterTileWidget extends StatelessWidget {
  const ChapterTileWidget({
    super.key,
    this.onTap,
    this.onTapDownload,
    this.padding,
    this.title,
    this.language,
    this.downloadProgress = 0,
    this.uploadedAt,
    this.groups,
    this.isPrefetching = false,
    this.lastReadAt,
    this.opacity = 1,
  });

  final VoidCallback? onTap;
  final VoidCallback? onTapDownload;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final String? groups;
  final Language? language;
  final double downloadProgress;
  final DateTime? uploadedAt;
  final DateTime? lastReadAt;
  final bool isPrefetching;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
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
                      IconWithTextWidget(
                        icon: const Icon(Icons.menu_book_outlined, size: 20),
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
                if (downloadProgress == 1)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.download_done, size: 20),
                  )
                else if (downloadProgress == 0 ||
                    downloadProgress.isNaN ||
                    downloadProgress.isInfinite)
                  if (onTapDownload != null)
                    IconButton(
                      onPressed: onTapDownload,
                      icon: const Icon(Icons.download, size: 20),
                    )
                else
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: downloadProgress,
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
