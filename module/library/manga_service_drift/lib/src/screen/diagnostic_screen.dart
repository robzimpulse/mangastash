import 'package:flutter/material.dart';


import '../dao/diagnostic_dao.dart';
import '../database/database.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key, required this.database});

  final AppDatabase database;

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  late final DiagnosticDao _diagnosticDao = DiagnosticDao(widget.database);

  late final _menus = <String, WidgetBuilder>{
    'Duplicated Manga': (context) {
      return StreamBuilder(
        stream: _diagnosticDao.duplicateManga,
        builder: (context, snapshot) {
          final data = snapshot.data?.entries;
          final error = snapshot.error;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (error != null) {
            return Center(child: Text(error.toString()));
          }

          if (data == null || data.isEmpty) {
            return Center(child: Text('No Data'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final value = data.elementAtOrNull(index);

              return ExpansionTile(
                title: Text('${value?.key.$1}'),
                subtitle: Text('${value?.key.$2}'),
                children: [
                  for (final child in value?.value ?? <MangaDrift>[])
                    ListTile(title: Text(child.id)),
                ],
              );
            },
          );
        },
      );
    },
    'Duplicated Chapter': (context) {
      return Container();
    },
    'Duplicated Tag': (context) {
      return Container();
    },
    'Orphaned Chapter': (context) {
      return Container();
    },
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _menus.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Database Diagnostic'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [..._menus.entries.map((e) => Tab(text: e.key))],
          ),
        ),
        body: TabBarView(
          children: [..._menus.entries.map((e) => e.value(context))],
        ),
      ),
    );
  }
}
