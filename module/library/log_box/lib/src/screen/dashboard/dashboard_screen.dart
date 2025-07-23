import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../manager/storage.dart';
import '../../model/entry.dart';
import '../../model/log_entry.dart';
import '../../model/navigation_entry.dart';
import '../../model/network_entry.dart';
import '../../model/webview_entry.dart';
import '../detail/detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.storage});

  final Storage storage;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<String> keyword = ValueNotifier('');
  final ValueNotifier<bool> isSearchMode = ValueNotifier(false);
  final ValueNotifier<Set<Type>> types = ValueNotifier({});

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    keyword.dispose();
    isSearchMode.dispose();
    types.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    final isSearch = isSearchMode.value;
    isSearchMode.value = !isSearch;
    if (!isSearch) {
      keyword.value = '';
      searchController.clear();
      focusNode.unfocus();
    }
  }

  bool _filter({
    required Entry value,
    required String keyword,
    Set<Type> types = const {},
  }) {
    return [
      value.contains(keyword),
      if (types.isNotEmpty) types.contains(value.runtimeType),
    ].every((e) => e);
  }

  Widget _item({required BuildContext context, required Entry value}) {
    void onTap() {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: 'Log Box Detail'),
          builder: (context) => DetailScreen(data: value),
        ),
      );
    }

    final hasDetail = value.tabs(context).isNotEmpty;

    return ListTile(
      onTap: hasDetail ? onTap : null,
      visualDensity: VisualDensity.compact,
      title: value.title(context),
      subtitle: value.subtitle(context),
      trailing: hasDetail ? const Icon(Icons.chevron_right) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !isSearchMode.value,
      onPopInvokedWithResult: (success, _) => !success ? _toggleSearch() : {},
      child: Scaffold(
        appBar: AppBar(
          actions: [
            ValueListenableBuilder(
              valueListenable: isSearchMode,
              builder: (context, isSearch, _) {
                return IconButton(
                  onPressed: _toggleSearch,
                  icon: Icon(isSearch ? Icons.close : Icons.search),
                );
              },
            ),
            IconButton(
              onPressed: () => widget.storage.clear(),
              icon: const Icon(Icons.delete),
            ),
          ],
          title: ValueListenableBuilder(
            valueListenable: isSearchMode,
            builder: (context, isSearch, _) {
              if (!isSearch) return const Text('Log Dashboard');
              return Container(
                alignment: Alignment.centerLeft,
                child: TextField(
                  autofocus: true,
                  onChanged: (text) => keyword.value = text,
                  focusNode: focusNode,
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    filled: false,
                    border: InputBorder.none,
                    hintStyle: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  cursorColor: Colors.white,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_types(), Expanded(child: _content())],
          ),
        ),
      ),
    );
  }

  Widget _types() {
    return StreamBuilder(
      stream: widget.storage.type,
      builder: (context, snapshot) {
        final data = snapshot.data;

        if (data == null || data.isEmpty) return const SizedBox.shrink();

        String text(Type type) => switch (type.toString()) {
          'NavigationEntry' => 'Navigation',
          'WebviewEntry' => 'Webview',
          'NetworkEntry' => 'Network',
          'LogEntry' => 'Log',
          _ => 'Undefined',
        };

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            scrollDirection: Axis.horizontal,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              direction: Axis.horizontal,
              children: [
                for (final type in data.sortedBy(text))
                  ValueListenableBuilder(
                    valueListenable: types,
                    builder: (context, datas, child) {
                      final selected = datas.contains(type);
                      return OutlinedButton(
                        onPressed: () {
                          var data = {...datas};
                          selected ? data.remove(type) : data.add(type);
                          types.value = data;
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selected ? Colors.grey : null,
                        ),
                        child: child,
                      );
                    },
                    child: Text(text(type)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content() {
    return AnimatedBuilder(
      animation: Listenable.merge([keyword, types]),
      builder: (context, _) {
        return StreamBuilder(
          stream: widget.storage.all.map(
            (e) => [
              ...e.values
                  .where(
                    (e) => _filter(
                      value: e,
                      keyword: keyword.value,
                      types: types.value,
                    ),
                  )
                  .sorted((a, b) => b.timestamp.compareTo(a.timestamp)),
            ],
          ),
          builder: (context, snapshot) {
            final data = snapshot.data;

            if (data == null) {
              return const CircularProgressIndicator();
            }

            return ListView.separated(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final entry = data.elementAtOrNull(index);
                if (entry == null) return null;
                return _item(context: context, value: entry);
              },
              separatorBuilder: (context, index) {
                return const Divider(height: 1);
              },
            );
          },
        );
      },
    );
  }
}
