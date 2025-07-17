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
      searchController.clear();
      focusNode.unfocus();
    }
  }

  bool _filter(Entry value) {
    if (value is LogEntry) {
      return value.message.toLowerCase().contains(keyword.value.toLowerCase());
    }

    if (value is NavigationEntry) {
      return [
        value.route?.toLowerCase().contains(
          keyword.value.toLowerCase(),
        ),
        value.previousRoute?.toLowerCase().contains(
          keyword.value.toLowerCase(),
        ),
      ].nonNulls.contains(true);
    }

    if (value is NetworkEntry) {
      return value.uri.toLowerCase().contains(keyword.value.toLowerCase());
    }

    if (value is WebviewEntry) {
      return value.uri.toLowerCase().contains(keyword.value.toLowerCase());
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
                  return const Text('Log Dashboard');
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
            bottom: TabBar(
              tabAlignment: TabAlignment.start,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              isScrollable: true,
              tabs: [
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.list_alt, size: 24),
                        const SizedBox(height: 4),
                        StreamBuilder(
                          stream: widget.storage.all,
                          builder: (context, snapshot) {
                            return Text('All (${snapshot.data?.length ?? 0})');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bug_report, size: 24),
                        const SizedBox(height: 4),
                        StreamBuilder(
                          stream: widget.storage.typed<LogEntry>(),
                          builder: (context, snapshot) {
                            return Text(
                              'Logging (${snapshot.data?.length ?? 0})',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.navigation, size: 24),
                        const SizedBox(height: 4),
                        StreamBuilder(
                          stream: widget.storage.typed<NavigationEntry>(),
                          builder: (context, snapshot) {
                            return Text(
                              'Navigation (${snapshot.data?.length ?? 0})',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.public, size: 24),
                        const SizedBox(height: 4),
                        StreamBuilder(
                          stream: widget.storage.typed<NetworkEntry>(),
                          builder: (context, snapshot) {
                            return Text(
                              'Network (${snapshot.data?.length ?? 0})',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_browser, size: 24),
                        const SizedBox(height: 4),
                        StreamBuilder(
                          stream: widget.storage.typed<WebviewEntry>(),
                          builder: (context, snapshot) {
                            return Text(
                              'Webview (${snapshot.data?.length ?? 0})',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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

  Widget _content({required Stream<List<Entry>> stream}) {
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
            final filtered =
                isSearchMode.value && keyword.value.isNotEmpty
                    ? data.where(_filter)
                    : data;

            if (filtered.isEmpty) {
              return const Center(child: Text('No Data'));
            }

            return ListView.separated(
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
