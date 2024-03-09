import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'browse_manga_cubit.dart';
import 'browse_manga_state.dart';

class BrowseMangaScreen extends StatelessWidget {
  const BrowseMangaScreen({
    super.key,
    this.source,
  });

  final MangaSource? source;

  static Widget create({
    required ServiceLocator locator,
    MangaSource? source,
  }) {
    return BlocProvider(
      create: (context) => BrowseMangaCubit()..init(),
      child: BrowseMangaScreen(
        source: source,
      ),
    );
  }

  BrowseMangaCubit _cubit(BuildContext context) {
    return context.read();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldScreen(
      onWillPop: () => Future.value(true),
      appBar: AppBar(
        title: Text('Browse Manga on ${source?.name}'),
      ),
      body: BlocBuilder<BrowseMangaCubit, BrowseMangaState>(
        builder: (context, state) => RefreshIndicator(
          onRefresh: () => _cubit(context).init(),
          child: Container(),
        ),
      ),
    );
  }
}
