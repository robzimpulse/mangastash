import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_misc_screen_cubit.dart';
import 'manga_misc_screen_state.dart';

class MangaMiscScreen extends StatefulWidget {
  const MangaMiscScreen({super.key, this.controller});

  final ScrollController? controller;

  static Widget create({
    required ServiceLocator locator,
    MangaChapterConfig? config,
    ScrollController? controller,
  }) {
    return BlocProvider(
      create: (context) => MangaMiscScreenCubit(
        initialState: MangaMiscScreenState(
          config: config ?? const MangaChapterConfig(),
        ),
      ),
      child: MangaMiscScreen(
        controller: controller,
      ),
    );
  }

  @override
  State<MangaMiscScreen> createState() => _MangaMiscScreenState();
}

class _MangaMiscScreenState extends State<MangaMiscScreen> {
  final ValueNotifier<Size> size = ValueNotifier(
    const Size(double.infinity, 500),
  );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: CustomScrollView(
        controller: widget.controller,
        slivers: [
          const SliverPinnedHeader(
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(text: 'Filter'),
                Tab(text: 'Sort'),
                Tab(text: 'Display'),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AutoScaleTabBarView(
                  children: [
                    _filter(context),
                    _sort(context),
                    _display(context),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _builder(
                    buildWhen: (prev, curr) => prev.config != curr.config,
                    builder: (context, state) => OutlinedButton(
                      onPressed: () => context.pop(state.config),
                      child: Text(
                        'Apply',
                        style: Theme.of(context).textTheme.titleMedium,
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

  MangaMiscScreenCubit _cubit(BuildContext context) => context.read();

  Widget _builder({
    required BlocWidgetBuilder<MangaMiscScreenState> builder,
    BlocBuilderCondition<MangaMiscScreenState>? buildWhen,
  }) {
    return BlocBuilder<MangaMiscScreenCubit, MangaMiscScreenState>(
      buildWhen: buildWhen,
      builder: builder,
    );
  }

  Widget _filter(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _builder(
          buildWhen: (prev, curr) => [
            prev.config?.downloaded != curr.config?.downloaded,
          ].contains(true),
          builder: (context, state) => CheckboxListTile(
            tristate: true,
            value: state.config?.downloaded,
            onChanged: (value) => _cubit(context).update(
              downloaded: () => value,
            ),
            title: const Text('Downloaded'),
          ),
        ),
        _builder(
          buildWhen: (prev, curr) => [
            prev.config?.unread != curr.config?.unread,
          ].contains(true),
          builder: (context, state) => CheckboxListTile(
            tristate: true,
            value: state.config?.unread,
            onChanged: (value) => _cubit(context).update(
              unread: () => value,
            ),
            title: const Text('Unread'),
          ),
        ),
        _builder(
          buildWhen: (prev, curr) => [
            prev.config?.bookmarked != curr.config?.bookmarked,
          ].contains(true),
          builder: (context, state) => CheckboxListTile(
            tristate: true,
            value: state.config?.bookmarked,
            onChanged: (value) => _cubit(context).update(
              bookmarked: () => value,
            ),
            title: const Text('Bookmarked'),
          ),
        ),
      ],
    );
  }

  Widget _sort(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final options in MangaChapterSortOptionEnum.values)
          _builder(
            buildWhen: (prev, curr) => [
              prev.config?.sortOption != curr.config?.sortOption,
              prev.config?.sortOrder != curr.config?.sortOrder,
            ].contains(true),
            builder: (context, state) => ListTile(
              leading: (state.config?.sortOption == options)
                  ? (state.config?.sortOrder == MangaChapterSortOrderEnum.desc)
                      ? const Icon(Icons.arrow_downward)
                      : const Icon(Icons.arrow_upward)
                  : SizedBox.fromSize(
                      size: Size(
                        IconTheme.of(context).size ?? 0,
                        IconTheme.of(context).size ?? 0,
                      ),
                    ),
              title: Text(options.value),
              onTap: () => _cubit(context).update(
                sortOption: options,
                sortOrder: (state.config?.sortOption == options)
                    ? (state.config?.sortOrder == MangaChapterSortOrderEnum.asc)
                        ? MangaChapterSortOrderEnum.desc
                        : MangaChapterSortOrderEnum.asc
                    : null,
              ),
            ),
          ),
      ],
    );
  }

  Widget _display(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final display in MangaChapterDisplayEnum.values)
          _builder(
            buildWhen: (prev, curr) => [
              prev.config?.display != curr.config?.display,
            ].contains(true),
            builder: (context, state) => RadioListTile<MangaChapterDisplayEnum>(
              title: Text(display.value),
              value: display,
              groupValue: state.config?.display,
              onChanged: (value) => _cubit(context).update(
                display: value,
              ),
            ),
          ),
      ],
    );
  }
}
