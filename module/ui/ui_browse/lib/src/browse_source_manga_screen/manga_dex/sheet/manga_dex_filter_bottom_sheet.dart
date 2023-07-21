import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class MangaDexFilterBottomSheet extends StatelessWidget {
  const MangaDexFilterBottomSheet({super.key, required this.tags});

  final List<MangaTag> tags;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 500),
      child: Padding(
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
                    child: const Text('Reset'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Filter'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ExpansionTileGroup(
              toggleType: ToggleType.expandOnlyCurrent,
              children: tags
                  .groupListsBy((e) => e.group)
                  .entries
                  .map<ExpansionTileItem>(
                    (e) => ExpansionTileItem(
                      title: Text(e.key?.toTitleCase() ?? ''),
                      children: e.value
                          .map(
                            (e) => CheckboxListTile(
                              title: Text(e.name ?? ''),
                              value: false,
                              onChanged: (value) {},
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
