import 'dart:developer';

import 'package:safe_bloc/safe_bloc.dart';
import 'package:service_locator/service_locator.dart';
import 'package:ui_common/ui_common.dart';

import 'manga_misc_cubit.dart';
import 'manga_misc_state.dart';

class MangaMiscBottomSheet extends StatefulWidget {
  const MangaMiscBottomSheet({super.key});

  static Widget create({
    required ServiceLocator locator,
  }) {
    return BlocProvider(
      create: (context) => MangaMiscCubit(
        initialState: const MangaMiscState(
          downloaded: false,
          unread: false,
          bookmarked: false,
        ),
      ),
      child: const MangaMiscBottomSheet(),
    );
  }

  @override
  State<MangaMiscBottomSheet> createState() => _MangaMiscBottomSheetState();
}

class _MangaMiscBottomSheetState extends State<MangaMiscBottomSheet> {
  final ValueNotifier<Size> _currentSize = ValueNotifier(Size.zero);

  MangaMiscCubit _cubit(BuildContext context) {
    return context.read<MangaMiscCubit>();
  }

  Widget _bloc({
    required BlocWidgetBuilder<MangaMiscState> builder,
    BlocBuilderCondition<MangaMiscState>? buildWhen,
  }) {
    return BlocBuilder<MangaMiscCubit, MangaMiscState>(
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
            return prev.downloaded != curr.downloaded;
          },
          builder: (context, state) => CheckboxListTile(
            tristate: true,
            value: state.downloaded,
            onChanged: (value) => _cubit(context).update(
              downloaded: () => value,
            ),
            title: const Text('Downloaded'),
          ),
        ),
        _bloc(
          buildWhen: (prev, curr) {
            return prev.unread != curr.unread;
          },
          builder: (context, state) => CheckboxListTile(
            tristate: true,
            value: state.unread,
            onChanged: (value) => _cubit(context).update(
              unread: () => value,
            ),
            title: const Text('Unread'),
          ),
        ),
        _bloc(
          buildWhen: (prev, curr) {
            return prev.bookmarked != curr.bookmarked;
          },
          builder: (context, state) => CheckboxListTile(
            tristate: true,
            value: state.bookmarked,
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
        for (final options in MangaMiscSortOptionEnum.values)
          _bloc(
            buildWhen: (prev, curr) {
              final isSortOptionChanged = prev.sortOption != curr.sortOption;
              final isSortOrderChanged = prev.sortOrder != curr.sortOrder;
              return isSortOptionChanged || isSortOrderChanged;
            },
            builder: (context, state) => ListTile(
              leading: (state.sortOption == options)
                  ? (state.sortOrder == MangaMiscSortOrderEnum.desc)
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
                sortOrder: (state.sortOption == options)
                    ? (state.sortOrder == MangaMiscSortOrderEnum.asc)
                        ? MangaMiscSortOrderEnum.desc
                        : MangaMiscSortOrderEnum.asc
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
        for (final display in MangaMiscDisplayEnum.values)
          _bloc(
            buildWhen: (prev, curr) => prev.display != curr.display,
            builder: (context, state) => RadioListTile<MangaMiscDisplayEnum>(
              title: Text(display.value),
              value: display,
              groupValue: state.display,
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
                    ChildSizeNotifierWidget(
                      builder: (context, size, _) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted) return;
                          _currentSize.value = size ?? Size.zero;
                        });
                        return _filter(context);
                      },
                    ),
                    const Spacer(),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ChildSizeNotifierWidget(
                      builder: (context, size, _) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted) return;
                          _currentSize.value = size ?? Size.zero;
                        });
                        return _sort(context);
                      },
                    ),
                    const Spacer(),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ChildSizeNotifierWidget(
                      builder: (context, size, _) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted) return;
                          _currentSize.value = size ?? Size.zero;
                        });
                        return _display(context);
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
