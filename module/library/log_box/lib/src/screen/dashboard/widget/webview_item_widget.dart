import 'package:flutter/material.dart';

import '../../../model/webview_entry.dart';

class WebviewItemWidget extends StatelessWidget {
  final WebviewEntry data;

  final VoidCallback? onTap;

  const WebviewItemWidget({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text('Entry for ${data.id}'),
      subtitle: Text('Type: ${data.runtimeType}'),
    );
  }
}
