import 'package:core_route/core_route.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_misc_screen_cubit.dart';
import 'manga_misc_screen_state.dart';

class MangaMiscScreen extends StatefulWidget {
  const MangaMiscScreen({super.key});

  static Widget create({
    required ServiceLocator locator,
    MangaChapterConfig? config,
  }) {
    return BlocProvider(
      create: (context) => MangaMiscScreenCubit(
        initialState: MangaMiscScreenState(
          config: config ?? const MangaChapterConfig(),
        ),
      ),
      child: const MangaMiscScreen(),
    );
  }

  @override
  State<MangaMiscScreen> createState() => _MangaMiscBottomScreen();
}

class _MangaMiscBottomScreen extends State<MangaMiscScreen> {
  final ValueNotifier<Size> _currentSize = ValueNotifier(Size.zero);

  MangaMiscScreenCubit _cubit(BuildContext context) => context.read();

  Widget _bloc({
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
        _bloc(
          buildWhen: (prev, curr) {
            return prev.config?.downloaded != curr.config?.downloaded;
          },
          builder: (context, state) => CheckboxListTile(
            tristate: true,
            value: state.config?.downloaded,
            onChanged: (value) => _cubit(context).update(
              downloaded: () => value,
            ),
            title: const Text('Downloaded'),
          ),
        ),
        _bloc(
          buildWhen: (prev, curr) {
            return prev.config?.unread != curr.config?.unread;
          },
          builder: (context, state) => CheckboxListTile(
            tristate: true,
            value: state.config?.unread,
            onChanged: (value) => _cubit(context).update(
              unread: () => value,
            ),
            title: const Text('Unread'),
          ),
        ),
        _bloc(
          buildWhen: (prev, curr) {
            return prev.config?.bookmarked != curr.config?.bookmarked;
          },
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
          _bloc(
            buildWhen: (prev, curr) {
              final isSortOptionChanged =
                  prev.config?.sortOption != curr.config?.sortOption;
              final isSortOrderChanged =
                  prev.config?.sortOrder != curr.config?.sortOrder;
              return isSortOptionChanged || isSortOrderChanged;
            },
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
          _bloc(
            buildWhen: (prev, curr) {
              return prev.config?.display != curr.config?.display;
            },
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      animationDuration: const Duration(milliseconds: 100),
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: 'Filter'),
              Tab(text: 'Sort'),
              Tab(text: 'Display'),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: _currentSize,
            builder: (context, size, child) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: BoxConstraints(maxHeight: size.height),
              child: child,
            ),
            child: TabBarView(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizeNotifierWidget(
                      size: (context, size) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted || size.isEmpty) return;
                          if (_currentSize.value.height > size.height) return;
                          _currentSize.value = size;
                        });
                      },
                      child: _filter(context),
                    ),
                    const Spacer(),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizeNotifierWidget(
                      size: (context, size) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted || size.isEmpty) return;
                          if (_currentSize.value.height > size.height) return;
                          _currentSize.value = size;
                        });
                      },
                      child: _sort(context),
                    ),
                    const Spacer(),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizeNotifierWidget(
                      size: (context, size) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted || size.isEmpty) return;
                          if (_currentSize.value.height > size.height) return;
                          _currentSize.value = size;
                        });
                      },
                      child: _display(context),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _bloc(
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
    );
  }
}
