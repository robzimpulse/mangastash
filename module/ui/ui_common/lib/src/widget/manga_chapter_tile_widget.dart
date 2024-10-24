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
    this.isDownloaded = false,
    this.uploadedAt,
    this.groups,
  });

  final VoidCallback? onTap;
  final VoidCallback? onTapDownload;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final String? title;
  final String? groups;
  final Language? language;
  final bool isDownloaded;
  final DateTime? uploadedAt;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconWithTextWidget(
                  icon: language?.flag(width: 20, height: 10),
                  text: Text(title ?? ' - '),
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
            if (isDownloaded)
              const Icon(Icons.download_done)
            else
              IconButton(
              onPressed: onTapDownload,
              icon: const Icon(Icons.download),
            ),
          ],
        ),
      ),
    );
  }
}
