import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Queues'),
      ),
      body: _builder(
        buildWhen: (prev, curr) => prev.jobs != curr.jobs,
        builder: (context, state) => CustomScrollView(
          slivers: [
            ...state.jobs.map(
              (e) => SliverToBoxAdapter(child: _jobItem(job: e)),
            ),
          ],
        ),
      ),
    );
  }
}
