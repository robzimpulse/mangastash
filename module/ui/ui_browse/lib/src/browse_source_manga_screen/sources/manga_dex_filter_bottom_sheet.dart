import 'package:flutter/material.dart';

class MangaDexFilterBottomSheet extends StatelessWidget {
  const MangaDexFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: const [
        ExpansionTile(
          title: Text('testing'),
          children: [
            Text('content'),
          ],
        ),
      ],
    );
  }

}