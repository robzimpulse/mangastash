import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class MangaDexFilterBottomSheet extends StatelessWidget {
  const MangaDexFilterBottomSheet({super.key, required this.tags});

  final List<MangaTag> tags;

  List<MapEntry<String?, List<MangaTag>>> get _tagsGroup {
    return tags.groupListsBy((e) => e.group).entries.toList();
  }

  Widget _content(BuildContext context) {
    return ExpansionTileGroup(
      toggleType: ToggleType.expandOnlyCurrent,
      children: _tagsGroup.map((e) => _group(context, e)).toList(),
    );
  }

  ExpansionTileItem _group(
    BuildContext context,
    MapEntry<String?, List<MangaTag>> e,
  ) {
    return ExpansionTileItem(
      themeData: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      title: Text(e.key?.toTitleCase() ?? ''),
      children: e.value.map((e) => _item(context, e)).toList(),
    );
  }

  Widget _item(BuildContext context, MangaTag e) {
    return CheckboxListTile(
      title: Text(e.name ?? ''),
      value: false,
      onChanged: (value) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      maxChildSize: 0.8,
      builder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
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
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: ListView(
                  controller: controller,
                  shrinkWrap: true,
                  children: [_content(context)],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
