import 'package:ui_common/ui_common.dart';

class MangaGridWidget extends GridWidget {
  MangaGridWidget({
    super.key,
    super.absorber,
    super.isLoading,
    super.onRefresh,
    super.onLoadNextPage,
    super.hasNextPage,
  }) : super(
          spacing: 10,
          crossAxisCount: 3,
          childAspectRatio: 100 / 140,
          builder: (context, index) => LayoutBuilder(
            builder: (context, constraint) => ConstrainedBox(
              constraints: constraint,
              // TODO: change to manga image
              child: Container(
                color: Colors.grey,
                child: Center(
                  child: Text('$index'),
                ),
              ),
            ),
          ),
        );
}
