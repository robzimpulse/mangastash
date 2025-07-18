import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common/storage.dart';
import '../../model/entry.dart';
import '../../model/log_entry.dart';
import '../../model/navigation_entry.dart';
import '../../model/network_entry.dart';
import '../../model/webview_entry.dart';
import 'widget/item_widget.dart';
import 'widget/log_item_widget.dart';
import 'widget/navigation_item_widget.dart';
import 'widget/network_item_widget.dart';
import 'widget/webview_item_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.storage, this.onTapSnapshot});

  final Storage storage;

  final Function(String? url, String? html)? onTapSnapshot;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final ValueNotifier<String> keyword = ValueNotifier('');
  final ValueNotifier<bool> isSearchMode = ValueNotifier(false);

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    keyword.dispose();
    isSearchMode.dispose();
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

  bool _filter({required Entry value, required String keyword}) {
    if (value is LogEntry) {
      return value.message.toLowerCase().contains(keyword.toLowerCase());
    }

    if (value is NavigationEntry) {
      return [
        value.route?.toLowerCase().contains(keyword.toLowerCase()),
        value.previousRoute?.toLowerCase().contains(keyword.toLowerCase()),
      ].nonNulls.contains(true);
    }

    if (value is NetworkEntry) {
      return value.uri?.toLowerCase().contains(keyword.toLowerCase()) ?? false;
    }

    if (value is WebviewEntry) {
      return value.uri.toLowerCase().contains(keyword.toLowerCase());
    }

    return false;
  }

  Widget _item(Entry value) {
    void onTap() {
      final id = value.id;
      // TODO: redirect to detail item
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) {
      //       return DetailScreen(
      //         data: value,
      //         onTapSnapshot: widget.onTapSnapshot,
      //       );
      //     },
      //   ),
      // );
    }

    if (value is LogEntry) {
      return LogItemWidget(data: value, onTap: onTap);
    }

    if (value is NavigationEntry) {
      return NavigationItemWidget(data: value);
    }

    if (value is NetworkEntry) {
      return NetworkItemWidget(data: value, onTap: onTap);
    }

    if (value is WebviewEntry) {
      return WebviewItemWidget(data: value, onTap: onTap);
    }

    return ItemWidget(data: value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !isSearchMode.value,
      onPopInvokedWithResult: (success, _) => !success ? _toggleSearch() : {},
      child: DefaultTabController(
        length: 5,
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
            bottom: TabBar(
              tabAlignment: TabAlignment.start,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              isScrollable: true,
              tabs: [
                _tab(
                  icon: Icons.list_alt,
                  title: 'All',
                  stream: widget.storage.all,
                ),
                _tab(
                  icon: Icons.bug_report,
                  title: 'Logging',
                  stream: widget.storage.typed<LogEntry>(),
                ),
                _tab(
                  icon: Icons.navigation,
                  title: 'Navigation',
                  stream: widget.storage.typed<NavigationEntry>(),
                ),
                _tab(
                  icon: Icons.public,
                  title: 'Network',
                  stream: widget.storage.typed<NetworkEntry>(),
                ),
                _tab(
                  icon: Icons.open_in_browser,
                  title: 'Webview',
                  stream: widget.storage.typed<WebviewEntry>(),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              children: [
                _content(stream: widget.storage.all),
                _content(stream: widget.storage.typed<LogEntry>()),
                _content(stream: widget.storage.typed<NavigationEntry>()),
                _content(stream: widget.storage.typed<NetworkEntry>()),
                _content(stream: widget.storage.typed<WebviewEntry>()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Tab _tab({
    required IconData icon,
    required String title,
    required Stream<List<Entry>> stream,
  }) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 4),
            ValueListenableBuilder(
              valueListenable: keyword,
              builder: (context, keyword, _) {
                return StreamBuilder(
                  stream: stream.map(
                    (e) => [
                      ...e.where((e) => _filter(value: e, keyword: keyword)),
                    ],
                  ),
                  builder: (context, snapshot) {
                    return Text('$title (${snapshot.data?.length ?? 0})');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _content({required Stream<List<Entry>> stream}) {
    return ValueListenableBuilder(
      valueListenable: keyword,
      builder: (context, keyword, _) {
        return StreamBuilder(
          stream: stream.map(
            (e) => [...e.where((e) => _filter(value: e, keyword: keyword))],
          ),
          builder: (context, snapshot) {
            final data = snapshot.data;

            if (data == null) {
              return const CircularProgressIndicator();
            }

            final filtered =
                keyword.isNotEmpty
                    ? data.where((e) => _filter(value: e, keyword: keyword))
                    : data;

            return ListView.separated(
              key: PageStorageKey('${stream.runtimeType}'),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final entry = filtered.elementAtOrNull(index);
                if (entry == null) return null;
                return _item(entry);
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
