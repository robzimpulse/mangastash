import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class MangaDexFilterBottomSheet extends StatelessWidget {
  const MangaDexFilterBottomSheet({super.key, required this.tags});

  final List<MangaTag> tags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        shrinkWrap: true,
        children: [
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Testing'),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Testing'),
              ),
            ],
          ),
          const Divider(height: 1),
          const ExpansionTile(
            title: Text('testing'),
            children: [
              Text('content'),
            ],
          ).divider(context: context, visible: false),
        ],
      ),
    );
  }
}
