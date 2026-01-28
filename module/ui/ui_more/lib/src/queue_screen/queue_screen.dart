import 'package:core_environment/core_environment.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ui_common/ui_common.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({
    super.key,
    required this.cancelJobUseCase,
    required this.listenJobUseCase,
  });

  final CancelJobUseCase cancelJobUseCase;
  final ListenJobUseCase listenJobUseCase;

  Widget _jobItem({required JobModel job, bool cancellable = true}) {
    final mangaTitle = job.manga?.title;
    final chapterTitle = job.chapter?.title;
    final imageUrl = job.image;

    return ListTile(
      title: Text('${job.id} - ${job.type.label}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mangaTitle != null) Text('Manga: $mangaTitle'),
          if (chapterTitle != null) Text('Chapter: $chapterTitle'),
          if (imageUrl != null) Text('Image: $imageUrl'),
        ],
      ),
      trailing:
          cancellable
              ? IconButton(
                onPressed: () => cancelJobUseCase.cancelJob(id: job.id),
                icon: Icon(Icons.cancel_outlined),
              )
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      appBar: AppBar(
        title: const Text('Queues'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StreamBuilder(
              stream: listenJobUseCase.upcomingJobLength,
              builder: (context, snapshot) {
                return IconWithTextWidget(
                  icon: Icon(Icons.pending_actions, size: 16),
                  text: Text('${snapshot.data ?? 0}'),
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: CombineLatestStream.combine2(
          listenJobUseCase.jobs,
          listenJobUseCase.ongoingJobId,
          (a, b) => (a, b),
        ),
        builder: (context, snapshot) {
          final data = snapshot.data;

          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final (jobs, ongoingJobId) = data;

          return ListView.builder(
            itemBuilder: (context, index) {
              final job = jobs.elementAtOrNull(index);
              if (job == null) return const SizedBox.shrink();
              return _jobItem(job: job, cancellable: ongoingJobId != job.id);
            },
            itemCount: jobs.length,
          );
        },
      ),
    );
  }
}
