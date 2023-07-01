import 'package:data_manga/data_manga.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'advanced_search_bottom_sheet_cubit.dart';
import 'advanced_search_bottom_sheet_cubit_state.dart';

class AdvancedSearchBottomSheet extends StatelessWidget {
  const AdvancedSearchBottomSheet({super.key});

  static Widget create({
    required ServiceLocator locator,
    List<Tag> tags = const [],
    TagsMode mode = TagsMode.and,
  }) {
    return BlocProvider(
      create: (context) => AdvancedSearchBottomSheetCubit(
        initialState: AdvancedSearchBottomSheetCubitState(
          tags: tags,
          originalTags: tags,
          mode: mode,
          originalMode: mode,
        ),
      ),
      child: const AdvancedSearchBottomSheet(),
    );
  }

  void _onTagsTogglePressed({
    required BuildContext context,
    required int index,
    required Tag? tag,
  }) {
    final cubit = context.read<AdvancedSearchBottomSheetCubit>();
    cubit.updateTag(index: index, tag: tag);
  }

  void _onTagsModeTogglePressed({
    required BuildContext context,
    required bool value,
  }) {
    final cubit = context.read<AdvancedSearchBottomSheetCubit>();
    cubit.updateTagsMode(value);
  }

  void _onTapReset(BuildContext context) {
    context.read<AdvancedSearchBottomSheetCubit>().reset();
  }

  void _onTapApply(BuildContext context) {
    final state = context.read<AdvancedSearchBottomSheetCubit>().state;
    context.pop(
      SearchMangaParameter(
        includedTags: state.includedTagsId,
        includedTagsMode: state.mode,
        excludedTags: state.excludedTagsId,
        excludedTagsMode: state.mode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              labelColor: !isDarkMode ? Colors.black : null,
              tabs: const [
                Tab(text: 'Tags'),
                Tab(text: 'Author'),
              ],
            ),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: TabBarView(
                children: [
                  Column(children: [_tagsList(), _tagsMode()]),
                  const Center(child: Text('Author View')),
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

  Widget _tags({
    required BuildContext context,
    required Tag tag,
  }) {
    return ListTile(
      title: Text(tag.name ?? ''),
      trailing: ToggleButtons(
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        isSelected: [tag.isExcluded, tag.isIncluded],
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        selectedColor: Colors.white,
        selectedBorderColor: Theme.of(context).primaryColorDark,
        fillColor: Theme.of(context).primaryColorDark,
        onPressed: (index) => _onTagsTogglePressed(
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

  Widget _tagsList() {
    return BlocBuilder<AdvancedSearchBottomSheetCubit,
        AdvancedSearchBottomSheetCubitState>(
      buildWhen: (prev, curr) => prev.tags != curr.tags,
      builder: (context, state) {
        return Expanded(
          child: ConditionalWidget(
            value: state.sortedTag.isNotEmpty,
            otherChild: const Center(
              child: Text('Empty Tags'),
            ),
            child: ListView(
              children: state.sortedTag
                  .map((e) => _tags(context: context, tag: e))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _tagsMode() {
    return BlocBuilder<AdvancedSearchBottomSheetCubit,
        AdvancedSearchBottomSheetCubitState>(
      buildWhen: (prev, curr) => prev.mode != curr.mode,
      builder: (context, state) {
        final name = state.mode.rawValue.toUpperCase();
        return SwitchListTile(
          visualDensity: VisualDensity.compact,
          title: Text('Tags Mode [$name]'),
          value: state.isTagModeAnd,
          onChanged: (value) => _onTagsModeTogglePressed(
            context: context,
            value: value,
          ),
        );
      },
    );
  }
}
