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
        downloadChapterProgressUseCase: locator(),
        listenActiveDownloadUseCase: locator(),
      ),
      child: const DownloadQueueScreen(),
    );
  }

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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${data.key.manga?.title}'),
                  Text('Chapter ${data.key.chapter?.chapter}'),
                  Text('${data.value.$1} files downloaded'),
                  LinearProgressIndicator(
                    value: data.value.$2,
                  ),
                ].intersperse(const SizedBox(height: 4)).toList(),
              ),
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
