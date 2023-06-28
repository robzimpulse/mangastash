import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      child: const Center(
        child: Text('Collection'),
      ),
    );
  }
}
