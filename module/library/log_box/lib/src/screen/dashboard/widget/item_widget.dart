import 'package:flutter/material.dart';

import '../../../model/entry.dart';

class ItemWidget extends StatelessWidget {
  final Entry data;

  final VoidCallback? onTap;

  const ItemWidget({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text('Entry for ${data.id}'),
      subtitle: Text('Type: ${data.runtimeType}'),
    );
  }
}
