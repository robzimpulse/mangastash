import 'package:ui_common/ui_common.dart';

class MangaGridWidget extends GridWidget {
  const MangaGridWidget({
    super.key,
    super.absorber,
    super.onRefresh,
    super.onLoadNextPage,
    super.hasNextPage,
    required super.builder,
  }) : super(
          spacing: 10,
          crossAxisCount: 3,
          childAspectRatio: 100 / 140,
        );
}
