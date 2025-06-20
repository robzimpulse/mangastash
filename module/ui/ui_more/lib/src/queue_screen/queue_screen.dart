import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'queue_screen_cubit.dart';
import 'queue_screen_state.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({
    super.key,
  });

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => QueueScreenCubit(
        listenDownloadProgressUseCase: locator(),
        listenPrefetchUseCase: locator(),
      ),
      child: const QueueScreen(),
    );
  }

  BlocBuilder _builder({
    required BlocWidgetBuilder<QueueScreenState> builder,
    BlocBuilderCondition<QueueScreenState>? buildWhen,
  }) {
    return BlocBuilder<QueueScreenCubit, QueueScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _jobItem({required JobModel job}) {
    return ListTile(
      title: Text('${job.id} - ${job.type.label}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manga: ${job.manga?.title}'),
          Text('Chapter: ${job.chapter?.title}'),
          Text('Image: ${job.image}'),
        ],
      ),
    );
  }

  Widget _downloadItem({
    required DownloadChapterKey key,
    required DownloadChapterProgress progress,
    required Map<String, String> filenames,
  }) {
    final child = progress.values.entries.where((e) => e.value < 1.0);
    return ExpansionTile(
      title: Text('${key.mangaTitle}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chapter ${key.chapterNumber}'),
          Text(
            '${progress.finish} files downloaded '
            'from ${progress.total} files',
          ),
          LinearProgressIndicator(
            value: progress.progress.toDouble(),
          ),
        ],
      ),
      children: List.of(
        child.map(
          (value) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(filenames[value.key] ?? value.key),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: value.value),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Queues'),
      ),
      body: Row(
        children: [
          Flexible(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Downloads',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: _builder(
                    buildWhen: (prev, curr) => [
                      prev.progress != curr.progress,
                      prev.filenames != curr.filenames,
                    ].contains(true),
                    builder: (context, state) => CustomScrollView(
                      slivers: List.of(
                        state.progress.entries.map(
                          (e) => SliverToBoxAdapter(
                            child: _downloadItem(
                              key: e.key,
                              progress: e.value,
                              filenames: state.filenames,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Prefetches',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Expanded(
                  child: _builder(
                    buildWhen: (prev, curr) => prev.jobs != curr.jobs,
                    builder: (context, state) => CustomScrollView(
                      slivers: List.of(
                        state.jobs.map(
                          (e) => SliverToBoxAdapter(
                            child: _jobItem(job: e),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
