import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_misc_cubit.dart';
import 'manga_misc_state.dart';

class MangaMiscBottomSheet extends StatefulWidget {
  const MangaMiscBottomSheet({super.key});

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => MangaMiscCubit(
        initialState: const MangaMiscState(),
      ),
      child: const MangaMiscBottomSheet(),
    );
  }

  @override
  State<MangaMiscBottomSheet> createState() => _MangaMiscBottomSheetState();
}

class _MangaMiscBottomSheetState extends State<MangaMiscBottomSheet> {
  MangaMiscCubit _cubit(BuildContext context) {
    return context.read<MangaMiscCubit>();
  }

  Widget _bloc({
    required BlocWidgetBuilder<MangaMiscState> builder,
    BlocBuilderCondition<MangaMiscState>? buildWhen,
  }) {
    return BlocBuilder<MangaMiscCubit, MangaMiscState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Filter'),
              Tab(text: 'Sort'),
              Tab(text: 'Display'),
            ],
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: const TabBarView(
              children: [
                Icon(Icons.directions_car),
                Icon(Icons.directions_transit),
                Icon(Icons.directions_bike),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
