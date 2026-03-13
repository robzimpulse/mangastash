import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_service_drift/manga_service_drift.dart';
import 'package:manga_service_drift/src/database/memory_executor.dart';
import 'package:manga_service_drift/src/screen/diagnostic_screen.dart';

void main() {
  testWidgets('NavigationExtension.diagnostic pushes DiagnosticScreen', (tester) async {

    final db = AppDatabase(executor: MemoryExecutor());

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => db.diagnostic(context: context),
                child: const Text('Nav'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Nav'));
    await tester.pumpAndSettle();

    expect(find.byType(DiagnosticScreen), findsOneWidget);
  });
}
