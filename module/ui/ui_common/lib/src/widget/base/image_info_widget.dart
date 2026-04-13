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
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      error.toString(),
                      maxLines: 3,
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  factory ImageInfoWidget.loading({required String url, double? progress}) {
    return ImageInfoWidget(
      child: (context) {
        return Center(child: CircularProgressIndicator(value: progress));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: child);
  }
}
