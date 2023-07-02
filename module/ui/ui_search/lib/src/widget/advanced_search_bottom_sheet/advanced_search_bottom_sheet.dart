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
    required List<Tag> tags,
    required SearchMangaParameter parameter,
  }) {
    return BlocProvider(
      create: (context) => AdvancedSearchBottomSheetCubit(
        initialState: AdvancedSearchBottomSheetCubitState(
          tags: tags,
          original: parameter,
          parameter: parameter,
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
    required bool isIncludedTag,
  }) {
    final cubit = context.read<AdvancedSearchBottomSheetCubit>();
    cubit.updateTagsMode(isIncludedTag: isIncludedTag, value: value);
  }

  void _onTapReset(BuildContext context) {
    context.read<AdvancedSearchBottomSheetCubit>().reset();
  }

  void _onTapApply(BuildContext context) {
    final state = context.read<AdvancedSearchBottomSheetCubit>().state;
    context.pop(state.parameter);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 6,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              isScrollable: true,
              labelColor: !isDarkMode ? Colors.black : null,
              tabs: const [
                Tab(text: 'Tags'),
                Tab(text: 'Author'),
                Tab(text: 'Artists'),
                Tab(text: 'Manga Status'),
                Tab(text: 'Original Language'),
                Tab(text: 'Available Translated Language'),
              ],
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 300,
              ),
              child: TabBarView(
                children: [
                  _tagsTabBarView(context),
                  const Center(child: Text('Author View')),
                  const Center(child: Text('Artists View')),
                  const Center(child: Text('Manga Status View')),
                  const Center(child: Text('Original Language View')),
                  const Center(child: Text('Available Translated View')),
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

  Widget _tagsTabBarView(BuildContext context) {
    return BlocBuilder<AdvancedSearchBottomSheetCubit,
        AdvancedSearchBottomSheetCubitState>(
      buildWhen: (prev, curr) => prev.parameter != curr.parameter,
      builder: (context, state) {
        final includedTagsModeName =
            state.parameter.includedTagsMode.rawValue.toUpperCase();
        final excludedTagsModeName =
            state.parameter.excludedTagsMode.rawValue.toUpperCase();

        return Column(
          children: [
            Expanded(
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
            ),
            SwitchListTile(
              visualDensity: VisualDensity.compact,
              title: Text('Included Tags Mode [$includedTagsModeName]'),
              value: state.parameter.includedTagsMode == TagsMode.and,
              onChanged: (value) => _onTagsModeTogglePressed(
                context: context,
                value: value,
                isIncludedTag: true,
              ),
            ),
            SwitchListTile(
              visualDensity: VisualDensity.compact,
              title: Text('Excluded Tags Mode [$excludedTagsModeName]'),
              value: state.parameter.excludedTagsMode == TagsMode.and,
              onChanged: (value) => _onTagsModeTogglePressed(
                context: context,
                value: value,
                isIncludedTag: false,
              ),
            ),
          ],
        );
      },
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
}
