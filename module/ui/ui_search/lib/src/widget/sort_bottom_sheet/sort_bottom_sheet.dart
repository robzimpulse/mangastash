import 'package:data_manga/data_manga.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'sort_bottom_sheet_cubit.dart';
import 'sort_bottom_sheet_cubit_state.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({super.key});

  static Widget create({
    required ServiceLocator locator,
    List<Tag> tags = const [],
  }) {
    return BlocProvider(
      create: (context) => SortBottomSheetCubit(
        initialState: SortBottomSheetCubitState(tags: tags, original: tags),
      ),
      child: const SortBottomSheet(),
    );
  }

  void _onTogglePressed({
    required BuildContext context,
    required int index,
    required Tag? tag,
  }) {
    var updated = tag;
    if (updated == null) return;
    final cubit = context.read<SortBottomSheetCubit>();
    cubit.update(
      updated.copyWith(
        isExcluded: index == 0 ? !updated.isExcluded : null,
        isIncluded: index == 1 ? !updated.isIncluded : null,
      ),
    );
  }

  Widget _tags({
    required BuildContext context,
    required Tag tag,
  }) {
    return ListTile(
      title: Text(tag.name ?? ''),
      trailing: ToggleButtons(
        isSelected: [tag.isExcluded, tag.isIncluded],
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        selectedColor: Colors.white,
        selectedBorderColor: Theme.of(context).primaryColorDark,
        fillColor: Theme.of(context).primaryColorDark,
        onPressed: (index) => _onTogglePressed(
          context: context,
          index: index,
          tag: tag,
        ),
        children: const [
          Icon(Icons.cancel_outlined),
          Icon(Icons.check_circle_outline),
        ],
      ),
    );
  }

  void _onTapReset(BuildContext context) {
    context.read<SortBottomSheetCubit>().reset();
  }

  void _onTapApply(BuildContext context) {
    final state = context.read<SortBottomSheetCubit>().state;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              labelColor: !isDarkMode ? Colors.black : null,
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
                  BlocBuilder<SortBottomSheetCubit, SortBottomSheetCubitState>(
                    builder: (context, state) {
                      return ConditionalWidget(
                        value: state.sortedTag.isNotEmpty,
                        otherChild: const Center(
                          child: Text('Empty Tags'),
                        ),
                        child: ListView(
                          children: state.sortedTag
                              .map((e) => _tags(context: context, tag: e))
                              .toList(),
                        ),
                      );
                    },
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
                    onPressed: () => _onTapReset(context),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _onTapApply(context),
                    child: const Text('Apply'),
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
