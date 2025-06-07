import 'package:core_environment/core_environment.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';

import 'icon_with_text_widget.dart';

class MangaChapterTileWidget extends StatelessWidget {
  const MangaChapterTileWidget({
    super.key,
    this.onTap,
    this.onTapDownload,
    this.onLongPress,
    this.padding,
    this.title,
    this.language,
    this.downloadProgress = 0,
    this.uploadedAt,
    this.groups,
    this.isPrefetching = false,
    this.lastReadAt,
  });

  final VoidCallback? onTap;
  final VoidCallback? onTapDownload;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final String? groups;
  final Language? language;
  final double downloadProgress;
  final DateTime? uploadedAt;
  final DateTime? lastReadAt;
  final bool isPrefetching;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Opacity(
        opacity: lastReadAt != null ? 0.5 : 1,
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
    );
  }
}
