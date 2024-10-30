import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'download_queue_screen_cubit.dart';
import 'download_queue_screen_state.dart';

class DownloadQueueScreen extends StatelessWidget {
  const DownloadQueueScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => DownloadQueueScreenCubit(
        downloadChapterUseCase: locator(),
        downloadChapterProgressStreamUseCase: locator(),
        downloadChapterProgressUseCase: locator(),
      ),
      child: const DownloadQueueScreen(),
    );
  }

  DownloadQueueScreenCubit _cubit(BuildContext context) => context.read();

  Widget _builder({
    required BlocWidgetBuilder<DownloadQueueScreenState> builder,
    BlocBuilderCondition<DownloadQueueScreenState>? buildWhen,
  }) {
    return BlocBuilder<DownloadQueueScreenCubit, DownloadQueueScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _content(BuildContext context, DownloadQueueScreenState state) {
    final progress = state.progress?.entries ?? [];
    return MultiSliver(
      children: [
        for (final data in progress)
          SliverToBoxAdapter(
            child: ListTile(
              title: Text('${data.key}'),
              subtitle: Text('${data.value}'),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Download Queue'),
      ),
      body: _builder(
        builder: (context, state) => CustomScrollView(
          slivers: [_content(context, state)],
        ),
      ),
    );
  }
}
