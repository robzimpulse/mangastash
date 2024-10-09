import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';

import 'picker_bottom_sheet_cubit.dart';
import 'picker_bottom_sheet_state.dart';

class PickerBottomSheet extends StatelessWidget {
  const PickerBottomSheet({super.key});

  static Widget create({
    required ServiceLocator locator,
    List<String> options = const [],
    String? selected,
  }) {
    return BlocProvider(
      create: (_) => PickerBottomSheetCubit(
        initialState: PickerBottomSheetState(options: options),
      ),
      child: const PickerBottomSheet(),
    );
  }

  PickerBottomSheetCubit _cubit(BuildContext context) => context.read();

  Widget _builder({
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
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
        Expanded(
          child: _builder(
            builder: (context, state) => ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) => ListTile(
                title: Text(state.filtered[index]),
                trailing: Visibility(
                  visible: state.filtered[index] == state.selected,
                  child: const Icon(Icons.check),
                ),
                onTap: () => context.pop(state.filtered[index]),
              ),
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
              ),
              itemCount: state.filtered.length,
            ),
          ),
        ),
      ],
    );
  }
}
