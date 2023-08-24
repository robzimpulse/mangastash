import 'package:collection/collection.dart';
import 'package:core_route/core_route.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:ui_common/ui_common.dart';

import 'filter_bottom_sheet_cubit.dart';
import 'filter_bottom_sheet_state.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  static Widget create({
  required ListenListTagUseCase listenListTagUseCase,
    List<String> includedTags = const [],
    List<String> excludedTags = const [],
  }) {
    return BlocProvider(
      create: (context) => FilterBottomSheetCubit(
        initialState: FilterBottomSheetState(
          originalIncludedTags: includedTags,
          originalExcludedTags: excludedTags,
          includedTags: includedTags,
          excludedTags: excludedTags,
        ),
        listenListTagUseCase: listenListTagUseCase,
      ),
      child: const FilterBottomSheet(),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  FilterBottomSheetCubit _cubit(BuildContext context) {
    return context.read<FilterBottomSheetCubit>();
  }

  Widget _bloc({
    required BlocWidgetBuilder<FilterBottomSheetState> builder,
    BlocBuilderCondition<FilterBottomSheetState>? buildWhen,
  }) {
    return BlocBuilder<FilterBottomSheetCubit, FilterBottomSheetState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _content(BuildContext context) {
    return _bloc(
      builder: (context, state) => ExpansionTileGroup(
        toggleType: ToggleType.expandOnlyCurrent,
        children: state.groups
            .sorted((a, b) => a.key?.compareTo(b.key ?? '') ?? 0)
            .map((e) => _group(context, e))
            .toList(),
      ),
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
      children: e.value
          .sorted((a, b) => a.name?.compareTo(b.name ?? '') ?? 0)
          .map((e) => _item(context, e))
          .toList(),
    );
  }

  Widget _item(BuildContext context, MangaTag e) {
    return CheckboxListTile(
      title: Text(e.name ?? ''),
      value: e.isIncluded == true
          ? e.isIncluded
          : e.isExcluded == true
              ? null
              : false,
      onChanged: (value) => _cubit(context).onTapCheckbox(
        id: e.id,
        value: value,
      ),
      tristate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      builder: (context, controller) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _cubit(context).reset(),
                    child: const Text('Reset'),
                  ),
                  const Spacer(),
                  _bloc(
                    builder: (context, state) => ElevatedButton(
                      onPressed: () => context.pop(state.finalTag),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView(
                  controller: controller,
                  shrinkWrap: true,
                  children: [_content(context)],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
