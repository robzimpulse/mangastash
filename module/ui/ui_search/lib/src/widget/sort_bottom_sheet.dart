import 'package:data_manga/data_manga.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_common/ui_common.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({super.key, required this.tags});

  final List<Tag> tags;

  void _onTogglePressed({
    required BuildContext context,
    required int index,
    required String key,
  }) {
    context.showSnackBar(message: 'tapped on index $index for key $key');
  }

  Widget _tags({
    required BuildContext context,
    required Tag tag,
  }) {
    return ListTile(
      title: Text(tag.name ?? ''),
      trailing: ToggleButtons(
        isSelected: const [true, false],
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        selectedColor: Colors.white,
        selectedBorderColor: Colors.green,
        fillColor: Colors.greenAccent,
        onPressed: (index) => _onTogglePressed(
          context: context,
          index: index,
          key: tag.id ?? '',
        ),
        children: const [
          Icon(Icons.cancel_outlined),
          Icon(Icons.check_circle_outline),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = tags.map((e) => _tags(context: context, tag: e));
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              labelColor: Theme.of(context).primaryColorDark,
              tabs: const [
                Tab(text: 'Sort'),
                Tab(text: 'Tags'),
                Tab(text: 'Authors'),
              ],
            ),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ),
              child: TabBarView(
                children: [
                  const Center(child: Text('Sort View')),
                  ConditionalWidget(
                    value: tags.isNotEmpty,
                    otherChild: const Center(
                      child: Text('Empty Tags'),
                    ),
                    child: ListView(
                      children: data.toList(),
                    ),
                  ),
                  const Center(child: Text('Authors View')),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: const Text('Reset'),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    child: const Text('Apply'),
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
