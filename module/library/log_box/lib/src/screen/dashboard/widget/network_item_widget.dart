import 'package:flutter/material.dart';

import '../../../model/network_entry.dart';

class NetworkItemWidget extends StatelessWidget {
  final NetworkEntry data;

  final VoidCallback? onTap;

  const NetworkItemWidget({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text('Entry for ${data.id}'),
      subtitle: Text('Type: ${data.runtimeType}'),
    );
  }
}
