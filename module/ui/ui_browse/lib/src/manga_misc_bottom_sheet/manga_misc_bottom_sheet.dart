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
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      builder: (context, controller) => CustomScrollView(
        controller: controller,
        slivers: const [
          SliverToBoxAdapter(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('🚧🚧🚧 Under Construction 🚧🚧🚧'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
