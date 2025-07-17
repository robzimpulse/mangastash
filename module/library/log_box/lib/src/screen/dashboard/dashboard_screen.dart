import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common/storage.dart';
import '../../model/log_entry.dart';
import '../../model/navigation_entry.dart';
import '../../model/network_entry.dart';
import '../../model/webview_entry.dart';

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
      searchController.clear();
      focusNode.unfocus();
    }
  }

  bool _filter<T>(T value) {
    if (value is LogEntry) {
      return value.message.contains(keyword.value);
    }

    if (value is NavigationEntry) {
      return [
        value.route?.settings.name?.contains(keyword.value),
        value.previousRoute?.settings.name?.contains(keyword.value),
      ].nonNulls.contains(true);
    }

    if (value is NetworkEntry) {
      return value.uri.contains(keyword.value);
    }

    if (value is WebviewEntry) {
      return value.uri.contains(keyword.value);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
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
                if (!isSearch) {
                  return const Text('Log Activities');
                }
                final titleLarge = Theme.of(context).textTheme.titleLarge;
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
                      hintStyle: titleLarge?.copyWith(color: Colors.white),
                    ),
                    cursorColor: Colors.white,
                    style: titleLarge?.copyWith(color: Colors.white),
                  ),
                );
              },
            ),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Log'),
                Tab(text: 'Navigation'),
                Tab(text: 'Network'),
                Tab(text: 'Webview'),
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

  Widget _content<T>({required Stream<List<T>> stream}) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        final data = snapshot.data;

        if (data == null) {
          return const CircularProgressIndicator();
        }

        return AnimatedBuilder(
          animation: Listenable.merge([isSearchMode, keyword]),
          builder: (context, _) {
            final filtered = data.where(_filter);

            if (filtered.isEmpty) {
              return const Center(child: Text('No Data'));
            }

            return ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (BuildContext context, int index) {
                final entry = filtered.elementAtOrNull(index);
                if (entry == null) return null;
                return ListTile(
                  title: Text('Entry for $index'),
                  subtitle: Text('Type: ${entry.runtimeType}'),
                );
              },
            );
          },
        );
      },
    );
  }
}
