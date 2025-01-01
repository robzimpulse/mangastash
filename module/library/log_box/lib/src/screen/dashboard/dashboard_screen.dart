import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common/log_storage.dart';
import '../../common/sort_log_enum.dart';
import '../../model/log_model.dart';
import 'widget/item_log_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.storage});

  final LogStorage storage;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();

  String query = '';
  bool isSearch = false;
  SortLog currentSort = SortLog.byTime;

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      isSearch = !isSearch;
      if (!isSearch) {
        searchController.clear();
        focusNode.unfocus();
      }
    });
  }

  void _search(String query) {
    setState(() {
      this.query = query;
    });
  }

  void _sort(SortLog sortType) {
    setState(() {
      currentSort = sortType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSearch,
      onPopInvoked: (success) => !success ? _toggleSearch() : {},
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(isSearch ? Icons.close : Icons.search),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.sort),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: SortLog.byTime,
                    child: Text('Time'),
                  ),
                  const PopupMenuItem(
                    value: SortLog.byName,
                    child: Text('Name'),
                  ),
                ];
              },
              onSelected: _sort,
            ),
          ],
          title: _title(context),
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          child: const Icon(Icons.delete),
          onPressed: () => widget.storage.clear(),
        ),
        body: StreamBuilder(
          stream: widget.storage.activities.map(
            (value) {
              final data = !isSearch
                  ? value
                  : value.where(
                      (activity) {
                        final text = activity.toString().toLowerCase();
                        return text.contains(query.toLowerCase());
                      },
                    ).toList();

              int sortByTime(LogModel a, LogModel b) {
                final aTime = a.time;
                final bTime = b.time;
                if (aTime == null || bTime == null) return 0;
                return aTime.isBefore(bTime) ? -1 : 1;
              }

              int sortByName(LogModel a, LogModel b) {
                final aName = a.name;
                final bName = b.name;
                if (aName == null || bName == null) return 0;
                return aName.compareTo(bName);
              }

              return switch (currentSort) {
                SortLog.byTime => data.sorted(sortByTime),
                SortLog.byName => data.sorted(sortByName),
              };
            },
          ),
          builder: (context, snapshot) {
            final data = snapshot.data;

            if (data == null) {
              return const CircularProgressIndicator();
            }

            return _body(context: context, filteredActivities: data);
          },
        ),
      ),
    );
  }

  Widget _title(BuildContext context) {
    if (!isSearch) {
      return const Text('Log Activities');
    }
    final titleLarge = Theme.of(context).textTheme.titleLarge;
    return Container(
      alignment: Alignment.centerLeft,
      child: TextField(
        autofocus: true,
        onChanged: _search,
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
  }

  Widget _body({
    required BuildContext context,
    required List<LogModel> filteredActivities,
  }) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: filteredActivities.length,
            itemBuilder: (context, index) {
              var data = filteredActivities[index];
              return ItemLogWidget(
                data: data,
                // onTap: () => Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => DetailScreen(data: data),
                //   ),
                // ),
              );
            },
          ),
        ),
      ],
    );
  }
}
