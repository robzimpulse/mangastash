import 'package:collection/collection.dart';
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
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
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
          ),
          const Divider(height: 1),
          ...tags
              .groupListsBy((e) => e.group)
              .entries
              .map<Widget>(
                (e) => ExpansionTile(
                  title: Text(e.key ?? ''),
                  children: e.value
                      .map(
                        (e) => CheckboxListTile(
                          title: Text(e.name ?? ''),
                          value: false,
                          onChanged: (value) {},
                        ),
                      )
                      .toList(),
                ).divider(context: context, visible: false),
              )
              .toList(),
        ],
      ),
    );
  }
}
