import 'package:flutter/material.dart';

import '../../../model/navigation_entry.dart';

class NavigationItemWidget extends StatelessWidget {
  final NavigationEntry data;

  const NavigationItemWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Entry for ${data.id}'),
      subtitle: Text('Type: ${data.runtimeType}'),
    );
  }
}
