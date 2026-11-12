// SourceMovedBannerWidget (issue #206): the banner shown above a moved
// manga's chapter list. "Moved" means the source (a scraped script) no
// longer serves the host the manga was saved on, so the app freezes the
// manga: only stored data is served and it can no longer be updated — the
// banner explains exactly that, with the source's name and the dead host.
//
// Usage:
//   SourceMovedBannerWidget(sourceName: state.source?.name ?? '', host: host);
// Place it above the chapter list when `movedHost != null` (see
// MangaDetailScreenState.movedHost). Refresh actions stay wired: the gated
// use cases make them a no-op for a moved manga.
import 'package:flutter/material.dart';

class SourceMovedBannerWidget extends StatelessWidget {
  const SourceMovedBannerWidget({
    super.key,
    required this.sourceName,
    required this.host,
  });

  /// Display name of the source that moved away from [host].
  final String sourceName;

  /// The stored URL's host the source no longer serves.
  final String host;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.link_off, size: 18, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Source moved — $sourceName no longer serves $host. '
                "Showing your saved copy; this manga can't be updated.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
