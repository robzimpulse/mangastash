import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:sliver_tools/sliver_tools.dart';

import 'picker_bottom_sheet_cubit.dart';
import 'picker_bottom_sheet_state.dart';

class PickerBottomSheet extends StatelessWidget {
  const PickerBottomSheet({super.key, this.controller});

  final ScrollController? controller;

  static Widget create({
    required ServiceLocator locator,
    ScrollController? controller,
    List<String> options = const [],
    String? selected,
  }) {
    return BlocProvider(
      create: (_) => PickerBottomSheetCubit(
        initialState: PickerBottomSheetState(
          options: options,
          selected: selected,
        ),
      ),
      child: PickerBottomSheet(
        controller: controller,
      ),
    );
  }

  PickerBottomSheetCubit _cubit(BuildContext context) => context.read();

  BlocBuilder _builder({
    required BlocWidgetBuilder<PickerBottomSheetState> builder,
    BlocBuilderCondition<PickerBottomSheetState>? buildWhen,
  }) {
    return BlocBuilder<PickerBottomSheetCubit, PickerBottomSheetState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverPinnedHeader(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
              onChanged: (value) => _cubit(context).search(value),
              onSubmitted: (value) => _cubit(context).search(value),
            ),
          ),
        ),
        _builder(
          buildWhen: (prev, curr) => [
            prev.filtered != curr.filtered,
            prev.selected != curr.selected,
          ].contains(true),
          builder: (context, state) => MultiSliver(
            children: [
              ...state.filtered
                  .map<Widget>(
                    (e) => ListTile(
                      title: Text(e),
                      trailing: Visibility(
                        visible: e == state.selected,
                        child: const Icon(Icons.check),
                      ),
                      onTap: () => context.pop(e),
                    ),
                  )
                  .intersperse(const Divider(height: 1, thickness: 1))
                  .map((e) => SliverToBoxAdapter(child: e)),
            ],
          ),
        ),
      ],
    );
  }
}
