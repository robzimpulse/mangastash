import 'package:flutter/material.dart';

class ImageInfoWidget extends StatelessWidget {
  const ImageInfoWidget({super.key, required this.child});

  final WidgetBuilder child;

  factory ImageInfoWidget.error({
    required String url,
    required Object error,
    VoidCallback? onTapRefresh,
  }) {
    return ImageInfoWidget(
      child: (context) {
        return LayoutBuilder(
          builder: (context, constraint) {
            if (constraint.maxWidth > 200 && !constraint.hasBoundedHeight) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$error ($url)',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (onTapRefresh != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: onTapRefresh,
                      child: Text('Refresh'),
                    ),
                  ],
                ],
              );
            }

            return Icon(Icons.error);
          },
        );
      },
    );
  }

  factory ImageInfoWidget.loading({required String url, double? progress}) {
    return ImageInfoWidget(
      child: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 8,
            minWidth: 8,
            maxWidth: 32,
            maxHeight: 32,
          ),
          child: CircularProgressIndicator(value: progress),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Builder(builder: child),
    ));
  }
}
