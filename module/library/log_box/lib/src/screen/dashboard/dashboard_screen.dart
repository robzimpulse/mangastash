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
      if (value is LogEntry)
        value.message.toLowerCase().contains(keyword.toLowerCase())
      else if (value is NavigationEntry)
        [
          value.route?.toLowerCase().contains(keyword.toLowerCase()),
          value.previousRoute?.toLowerCase().contains(keyword.toLowerCase()),
        ].nonNulls.contains(true)
      else if (value is NetworkEntry)
        value.uri?.toLowerCase().contains(keyword.toLowerCase()) ?? false
      else if (value is WebviewEntry)
        value.uri.toString().toLowerCase().contains(keyword.toLowerCase()),

      if (types.isNotEmpty) types.contains(value.runtimeType),
    ].every((e) => e);
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
                for (final type in data)
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
                    child: Text(type.toString()),
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
              ...e.where(
                (e) => _filter(
                  value: e,
                  keyword: keyword.value,
                  types: types.value,
                ),
              ),
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
