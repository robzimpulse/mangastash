import 'dart:async';

import 'package:flutter/material.dart';

import '../../common/http_activity_storage.dart';
import '../../common/sort_activity_enum.dart';
import '../../model/http_activity_model.dart';

class DashboardScreen extends StatefulWidget {
  final String password;
  final HttpActivityStorage storage;

  const DashboardScreen({super.key, this.password = '', required this.storage});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TextEditingController searchController = TextEditingController();
  FocusNode focusNode = FocusNode();
  StreamSubscription<List<HttpActivityModel>>? activitiesSubscription;

  String query = '';
  bool isSearch = false;
  // List<HttpActivityModel> allActivities = [];
  // SortActivity currentSort = SortActivity.byTime;

  @override
  void initState() {
    super.initState();
    // activitiesSubscription =
    //     widget.storage.activities.distinct().listen(_onActivityUpdated);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // if (widget.password.isEmpty) return;
  //   // WidgetsBinding.instance.addPostFrameCallback((_) => _dialogInputPassword());
  // }

  @override
  void dispose() {
    activitiesSubscription?.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // void _onActivityUpdated(List<HttpActivityModel> activities) {
  //   setState(() {
  //     allActivities = activities;
  //   });
  // }
  //
  // List<HttpActivityModel> get filteredActivities {
  //   final filtered = !isSearch
  //       ? allActivities
  //       : switch (currentSort) {
  //           SortActivity.byTime => List.of(allActivities)
  //             ..sort(
  //               (a, b) => b.createdTime.compareTo(a.createdTime),
  //             ),
  //           SortActivity.byMethod => List.of(allActivities)
  //             ..sort(
  //               (a, b) => b.method.compareTo(a.method),
  //             ),
  //           SortActivity.byStatus => List.of(allActivities)
  //             ..sort(
  //               (a, b) =>
  //                   a.response?.status?.compareTo(b.response?.status ?? 0) ?? 0,
  //             ),
  //         };
  //
  //   return filtered.where(
  //     (activity) {
  //       final text = activity.toString().toLowerCase();
  //       return text.contains(query.toLowerCase());
  //     },
  //   ).toList();
  // }
  //
  // void _dialogInputPassword() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => PasswordProtectionDialog(
  //       password: widget.password,
  //     ),
  //   );
  // }
  //
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
  //
  // void _sortAllResponses(SortActivity sortType) {
  //   setState(() {
  //     currentSort = sortType;
  //   });
  // }

  Widget _title(BuildContext context) {
    if (!isSearch) {
      return const Text('Http Activities');
    }
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
          hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        cursorColor: Colors.white,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
        ),
      ),
    );
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
          ],
          title: _title(context),
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          child: const Icon(Icons.delete),
          onPressed: () => widget.storage.clear(),
        ),
        body: StreamBuilder(
          stream: widget.storage.activities,
          builder: (context, snapshot) {
            final data = snapshot.data;

            if (data == null) {
              return const CircularProgressIndicator();
            }

            if (data.isEmpty) {
              return const Text('No data');
            }

            return const Text('Data Exists');
          },
        ),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     leading: IconButton(
    //       onPressed: () {
    //         // if (isSearch) {
    //         //   _toggleSearch();
    //         //   return;
    //         // }
    //         // Navigator.pop(context);
    //       },
    //       icon: const Icon(Icons.arrow_back, color: Colors.black,),
    //     ),
    //     actions: [
    //       IconButton(
    //         onPressed: () {},
    //         // onPressed: _toggleSearch,
    //         icon: Icon(isSearch ? Icons.close : Icons.search),
    //       ),
    //       PopupMenuButton(
    //         icon: const Icon(Icons.sort),
    //         itemBuilder: (context) {
    //           return [
    //             const PopupMenuItem(
    //               value: SortActivity.byTime,
    //               child: Text('Time'),
    //             ),
    //             const PopupMenuItem(
    //               value: SortActivity.byMethod,
    //               child: Text('Method'),
    //             ),
    //             const PopupMenuItem(
    //               value: SortActivity.byStatus,
    //               child: Text('Status'),
    //             ),
    //           ];
    //         },
    //         onSelected: (value) {},
    //         // onSelected: _sortAllResponses,
    //       ),
    //     ],
    //
    //     title: !isSearch
    //         ? const Text('Http Activities')
    //         : TextField(
    //       autofocus: true,
    //       onChanged: (value) {},
    //       // onChanged: _search,
    //       focusNode: focusNode,
    //       controller: searchController,
    //       decoration: const InputDecoration(
    //         hintText: 'Search',
    //         focusedBorder: UnderlineInputBorder(
    //           borderSide: BorderSide(color: Colors.white),
    //         ),
    //         enabledBorder: UnderlineInputBorder(
    //           borderSide: BorderSide(color: Colors.white),
    //         ),
    //       ),
    //     ),
    //     title: Text('Test'),
    //     backgroundColor: Colors.white,
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     shape: const CircleBorder(),
    //     child: const Icon(Icons.delete),
    //     onPressed: () {
    //       // setState(() { allActivities.clear(); });
    //     },
    //   ),
    //   body: Container(
    //     color: Colors.white,
    //     child: Center(
    //       child: StreamBuilder(
    //         stream: widget.storage.activities,
    //         builder: (context, snapshot) {
    //           final data = snapshot.data;
    //
    //           if (data == null) {
    //             return const CircularProgressIndicator();
    //           }
    //
    //           if (data.isEmpty) {
    //             return const Text('No data');
    //           }
    //
    //           return const Text('Data Exists');
    //         },
    //       ),
    //     ),
    //   ),
    // );
  }
}
