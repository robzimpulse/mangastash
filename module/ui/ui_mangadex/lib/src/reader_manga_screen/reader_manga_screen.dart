import 'package:entity_manga/entity_manga.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'reader_manga_cubit.dart';
import 'reader_manga_state.dart';

class ReaderMangaScreen extends StatefulWidget {
  const ReaderMangaScreen({super.key});

  static Widget create({
    required ServiceLocator locator,
    required String? mangaId,
    required String? chapterId,
  }) {
    return BlocProvider(
      create: (context) => ReaderMangaCubit(
        initialState: ReaderMangaState(
          mangaId: mangaId,
          chapterId: chapterId,
        ),
        getChapterImageUseCase: locator(),
        getChapterUseCase: locator(),
      )..init(),
      child: const ReaderMangaScreen(),
    );
  }

  @override
  State<ReaderMangaScreen> createState() => _ReaderMangaScreenState();
}

class _ReaderMangaScreenState extends State<ReaderMangaScreen> {
  final _pageDataStream = BehaviorSubject<int>.seeded(0);

  Widget _builder({
    required BlocWidgetBuilder<ReaderMangaState> builder,
    BlocBuilderCondition<ReaderMangaState>? buildWhen,
  }) {
    return BlocBuilder<ReaderMangaCubit, ReaderMangaState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  void dispose() {
    _pageDataStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      body: _content(),
    );
  }

  Widget _content() {
    return _builder(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final images = state.chapter?.imagesDataSaver ?? [];

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView.builder(
              itemBuilder: (context, index) => VisibilityDetector(
                onVisibilityChanged: (info) {
                  final value = (info.key as ValueKey<int>?)?.value;
                  if (value == null) return;
                  _pageDataStream.add(value);
                },
                key: ValueKey<int>(index),
                child: CachedNetworkImage(
                  imageUrl: images[index],
                ),
              ),
              itemCount: images.length,
            ),
            StreamBuilder<int>(
                stream: _pageDataStream.stream,
                builder: (context, snapshot) {
                  return Positioned(
                    bottom: double.minPositive,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                      ),
                      child: Text(
                        'Page ${snapshot.data ?? 0} of ${images.length}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                }),
          ],
        );
      },
    );
  }
}
