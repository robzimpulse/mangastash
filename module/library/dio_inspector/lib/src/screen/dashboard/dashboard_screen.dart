import 'package:flutter/material.dart';

import '../../common/http_activity_storage.dart';
import '../../common/sort_activity_enum.dart';
import '../../model/http_activity_model.dart';
import '../detail/detail_screen.dart';
import 'widget/item_response_widget.dart';

class DashboardScreen extends StatefulWidget {
  final HttpActivityStorage storage;

  const DashboardScreen({super.key, required this.storage});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();

  String query = '';
  bool isSearch = false;
  SortActivity currentSort = SortActivity.byTime;

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

  void _sort(SortActivity sortType) {
    setState(() {
      currentSort = sortType;
    });
  }

  Widget _title(BuildContext context) {
    if (!isSearch) {
      return const Text('Http Activities');
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

  List<HttpActivityModel> _filter(List<HttpActivityModel> values) {
    final data = !isSearch
        ? values
        : [
            ...values.where(
              (activity) {
                final text = activity.toString().toLowerCase();
                return text.contains(query.toLowerCase());
              },
            ),
          ];

    return switch (currentSort) {
      SortActivity.byTime => List.of(data)
        ..sort(
          (a, b) => b.createdTime.compareTo(a.createdTime),
        ),
      SortActivity.byMethod => List.of(data)
        ..sort(
          (a, b) => b.method.compareTo(a.method),
        ),
      SortActivity.byStatus => List.of(data)
        ..sort(
          (a, b) => a.response?.status?.compareTo(b.response?.status ?? 0) ?? 0,
        ),
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
              onPressed: () => widget.storage.clear(),
              icon: const Icon(Icons.delete),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.sort),
              itemBuilder: (context) {
                return [
                  const PopupMenuItem(
                    value: SortActivity.byTime,
                    child: Text('Time'),
                  ),
                  const PopupMenuItem(
                    value: SortActivity.byMethod,
                    child: Text('Method'),
                  ),
                  const PopupMenuItem(
                    value: SortActivity.byStatus,
                    child: Text('Status'),
                  ),
                ];
              },
              onSelected: _sort,
            ),
          ],
          title: _title(context),
        ),
        body: SafeArea(
          child: StreamBuilder(
            stream: widget.storage.activities.map(_filter),
            builder: (context, snapshot) {
              final data = snapshot.data;

              if (data == null) {
                return const CircularProgressIndicator();
              }

              return _body(context: context, filteredActivities: data);
            },
          ),
        ),
      ),
    );
  }

  Widget _body({
    required BuildContext context,
    required List<HttpActivityModel> filteredActivities,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          child: Card(
            surfaceTintColor: Colors.transparent,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            // color: Colors.white,
            child: ListTileTheme(
              contentPadding: const EdgeInsets.all(0),
              dense: true,
              horizontalTitleGap: 0.0,
              minLeadingWidth: 0,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text('Total'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text('GET'),
                              const SizedBox(height: 4),
                              Text(
                                _getTotalRequest(
                                  getAllResponses: filteredActivities,
                                  method: 'get',
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('POST'),
                              const SizedBox(height: 4),
                              Text(
                                _getTotalRequest(
                                  getAllResponses: filteredActivities,
                                  method: 'post',
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('PUT'),
                              const SizedBox(height: 4),
                              Text(
                                _getTotalRequest(
                                  getAllResponses: filteredActivities,
                                  method: 'put',
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('PATCH'),
                              const SizedBox(height: 4),
                              Text(
                                _getTotalRequest(
                                  getAllResponses: filteredActivities,
                                  method: 'patch',
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('DELETE'),
                              const SizedBox(height: 4),
                              Text(
                                _getTotalRequest(
                                  getAllResponses: filteredActivities,
                                  method: 'delete',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final data = filteredActivities.elementAtOrNull(index);
              if (data == null) return null;
              return ItemResponseWidget(
                data: data,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(data: data),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getTotalRequest({
    required List<HttpActivityModel> getAllResponses,
    required String method,
  }) {
    return getAllResponses
        .where((e) => e.method.toLowerCase() == method)
        .length
        .toString();
  }
}
