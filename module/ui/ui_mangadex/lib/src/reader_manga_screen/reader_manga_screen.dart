import 'package:entity_manga/entity_manga.dart';
import 'package:flutter/material.dart';
import 'package:ui_common/ui_common.dart';

class ReaderMangaScreen extends StatelessWidget {
  const ReaderMangaScreen({
    super.key,
    required this.manga,
    this.initialChapterId,
  });

  final Manga manga;

  final String? initialChapterId;

  @override
  Widget build(BuildContext context) {
    final data = manga.chapters?.map((e) => e.images ?? []) ?? [];
    final images = data.expand((e) => e);

    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          const Positioned(
            bottom: double.minPositive,
            child: Text(
              'Page Indicator',
              style: TextStyle(fontSize: 10),
            ),
          ),
          ListView(
            children: [
              const SizedBox(
                height: 200,
                child: Center(
                  child: Text('There\'s no previous chapter'),
                ),
              ),
              ...images.map((e) => CachedNetworkImage(imageUrl: e)).toList(),
              const SizedBox(
                height: 200,
                child: Center(
                  child: Text('There\'s no next chapter'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
