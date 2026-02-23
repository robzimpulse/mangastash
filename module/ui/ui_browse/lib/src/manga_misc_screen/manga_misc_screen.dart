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
    ChapterConfig? config,
    ScrollController? controller,
  }) {
    return BlocProvider(
      create: (context) {
        return MangaMiscScreenCubit(
          initialState: MangaMiscScreenState(
            config: config ?? const ChapterConfig(),
          ),
        );
      },
      child: MangaMiscScreen(controller: controller),
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
                    builder: (context, state) {
                      return OutlinedButton(
                        onPressed: () => context.pop(state.config),
                        child: Text(
                          'Apply',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    },
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
          buildWhen: (prev, curr) {
            return prev.config?.downloaded != curr.config?.downloaded;
          },
          builder: (context, state) {
            return CheckboxListTile(
              tristate: true,
              value: state.config?.downloaded,
              onChanged: (e) => _cubit(context).update(downloaded: () => e),
              title: const Text('Downloaded'),
            );
          },
        ),
        _builder(
          buildWhen: (prev, curr) => prev.config?.unread != curr.config?.unread,
          builder: (context, state) {
            return CheckboxListTile(
              tristate: true,
              value: state.config?.unread,
              onChanged: (e) => _cubit(context).update(unread: () => e),
              title: const Text('Unread'),
            );
          },
        ),
      ],
    );
  }

  Widget _sort(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final options in ChapterSortOptionEnum.values)
          _builder(
            buildWhen: (prev, curr) {
              return [
                prev.config?.sortOption != curr.config?.sortOption,
                prev.config?.sortOrder != curr.config?.sortOrder,
              ].contains(true);
            },
            builder: (context, state) {
              final Widget leading;
              final ChapterSortOrderEnum? order;

              if (state.config?.sortOption == options) {
                if (state.config?.sortOrder == ChapterSortOrderEnum.desc) {
                  leading = Icon(Icons.arrow_downward);
                  order = ChapterSortOrderEnum.desc;
                } else {
                  leading = Icon(Icons.arrow_upward);
                  order = ChapterSortOrderEnum.asc;
                }
              } else {
                leading = SizedBox.fromSize(
                  size: Size(
                    IconTheme.of(context).size ?? 0,
                    IconTheme.of(context).size ?? 0,
                  ),
                );
                order = null;
              }

              return ListTile(
                leading: leading,
                title: Text(options.value),
                onTap: () {
                  _cubit(context).update(sortOption: options, sortOrder: order);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _display(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final display in ChapterDisplayEnum.values)
          _builder(
            buildWhen: (prev, curr) {
              return prev.config?.display != curr.config?.display;
            },
            builder: (context, state) {
              return RadioListTile<ChapterDisplayEnum>(
                title: Text(display.value),
                value: display,
                groupValue: state.config?.display,
                onChanged: (value) => _cubit(context).update(display: value),
              );
            },
          ),
      ],
    );
  }
}
