import 'package:collection/collection.dart';
import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:flutter/material.dart';

import '../../common/log_storage.dart';
import '../../common/sort_log_enum.dart';
import '../../model/log_html_model.dart';
import '../../model/log_model.dart';
import '../detail/detail_screen.dart';
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
  late final logs = widget.storage.activities.map(_filter);

  String query = '';
  bool isHtml = false;
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

  void _toggleHtml() {
    setState(() {
      isHtml = !isHtml;
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

  List<LogModel> _filter(List<LogModel> value) {
    var data = value;

    if (isSearch) {
      data = [
        ...data.where(
              (e) => e.message.toLowerCase().contains(query.toLowerCase()),
        ),
      ];
    }

    if (isHtml) {
      data = [...data.whereType<LogHtmlModel>()];
    }

    int sortByTime(LogModel a, LogModel b) {
      final aTime = a.time;
      final bTime = b.time;
      if (aTime == null || bTime == null) return 0;
      return aTime.isBefore(bTime) ? 1 : -1;
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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSearch,
      onPopInvokedWithResult: (success, _) => !success ? _toggleSearch() : {},
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: _toggleSearch,
              icon: Icon(isSearch ? Icons.close : Icons.search),
            ),
            IconButton(
              onPressed: _toggleHtml,
              icon: Icon(isHtml ? Icons.web_asset_off : Icons.web),
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
          stream: logs,
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

    if (filteredActivities.isEmpty) {
      return const Center(child: Text('No Data'));
    }

    final groups = filteredActivities.groupListsBy((e) => e.name);

    final tabs = groups.entries.mapIndexed(
      (index, entry) => TabData(
        index: index,
        title: Tab(child: Text(entry.key ?? 'Unnamed')),
        content: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: entry.value.length,
          itemBuilder: (context, index) => ItemLogWidget(
            data: entry.value[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(
                  data: entry.value[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Column(
      children: [
        Expanded(
          child: DynamicTabBarWidget(
            isScrollable: true,
            showBackIcon: false,
            showNextIcon: false,
            tabAlignment: TabAlignment.center,
            onTabChanged: (index) {},
            onTabControllerUpdated: (controller) {},
            dynamicTabs: tabs.toList(),
            onAddTabMoveTo: MoveToTab.idol,
          ),
        ),
      ],
    );
  }
}
