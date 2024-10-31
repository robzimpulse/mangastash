import 'dart:async';
import 'dart:math';

import 'package:core_storage/core_storage.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'manga_reader_screen_cubit.dart';
import 'manga_reader_screen_state.dart';

class MangaReaderScreen extends StatefulWidget {
  const MangaReaderScreen({super.key, this.cacheManager});

  final BaseCacheManager? cacheManager;

  static Widget create({
    required ServiceLocator locator,
    required MangaSourceEnum? source,
    required String? mangaId,
    required String? chapterId,
  }) {
    return BlocProvider(
      create: (context) => MangaReaderScreenCubit(
        initialState: MangaReaderScreenState(
          mangaId: mangaId,
          chapterId: chapterId,
          source: source,
        ),
        getChapterUseCase: locator(),
        getMangaSourceUseCase: locator(),
      )..init(),
      child: MangaReaderScreen(
        cacheManager: locator(),
      ),
    );
  }

  @override
  State<MangaReaderScreen> createState() => _MangaReaderScreenState();
}

class _MangaReaderScreenState extends State<MangaReaderScreen> {
  final _pageDataStream = BehaviorSubject<int>.seeded(0);

  Map<int, BehaviorSubject<double>> _pageSizeStreams = {};

  StreamSubscription? _subscription;

  Widget _builder({
    required BlocWidgetBuilder<MangaReaderScreenState> builder,
    BlocBuilderCondition<MangaReaderScreenState>? buildWhen,
    required BlocWidgetListener<MangaReaderScreenState> listener,
    BlocListenerCondition<MangaReaderScreenState>? listenWhen,
  }) {
    return BlocConsumer<MangaReaderScreenCubit, MangaReaderScreenState>(
      listenWhen: listenWhen,
      listener: listener,
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    _pageDataStream.close();
    _subscription?.cancel();
    for (var e in _pageSizeStreams.values) {
      e.close();
    }
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      bottomSafeArea: false,
      body: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    return _builder(
      listenWhen: (prev, curr) => prev.chapter?.images != curr.chapter?.images,
      listener: (context, state) {
        final images = (state.chapter?.images ?? []).asMap();
        _pageSizeStreams = images.map(
          (key, value) => MapEntry(
            key,
            BehaviorSubject<double>.seeded(0),
          ),
        );
        _subscription =
            Rx.combineLatestList(_pageSizeStreams.values.map((e) => e.stream))
                .map((event) => event.indexOf(event.reduce(max)))
                .listen((event) => _pageDataStream.add(event + 1));
      },
      buildWhen: (prev, curr) {
        return prev.isLoading != curr.isLoading ||
            prev.chapter?.images != curr.chapter?.images;
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final images = state.chapter?.images ?? [];

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView.builder(
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => VisibilityDetector(
                onVisibilityChanged: (info) {
                  if (!context.mounted) return;
                  _pageSizeStreams[index]?.add(info.visibleFraction);
                },
                key: ValueKey<int>(index),
                child: CachedNetworkImage(
                  cacheManager: widget.cacheManager,
                  imageUrl: images[index],
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                  ),
                  progressIndicatorBuilder: (context, url, progress) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            value: progress.progress,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              itemCount: images.length,
            ),
            StreamBuilder<int>(
              stream: _pageDataStream.stream,
              builder: (context, snapshot) {
                return Positioned(
                  bottom: double.minPositive,
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      child: Text(
                        'Page ${snapshot.data ?? 0} of ${images.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
