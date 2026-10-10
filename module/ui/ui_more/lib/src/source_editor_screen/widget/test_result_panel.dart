// TestResultPanel: shows one source-editor Test outcome (issue #115, spec
// §10) — the function, URL and elapsed time, then either the error (with its
// script `line N`) or the validation result, and the result JSON in a
// height-capped, scrollable monospace box.
//
// Usage: `TestResultPanel(run: state.lastRun!)` inside the editor screen.
import 'package:flutter/material.dart';

import '../source_editor_screen_state.dart';

class TestResultPanel extends StatelessWidget {
  const TestResultPanel({super.key, required this.run});

  final SourceTestRun run;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final error = run.error;
    final line = run.line;
    final validation = run.validation;
    final summary = run.summary;
    final json = run.json;
    final url = run.url;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${run.function} · ${run.elapsed.inMilliseconds} ms',
              style: theme.textTheme.titleSmall,
            ),
            if (url != null) Text(url, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            if (error != null) ...[
              Text(
                line == null ? 'Error' : 'Error at line $line',
                style: TextStyle(color: colors.error),
              ),
              Text(error, style: TextStyle(color: colors.error)),
            ] else if (validation != null)
              Text(
                'Validation failed: $validation',
                style: TextStyle(color: colors.error),
              )
            else if (summary != null)
              Text(summary),
            if (json != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: SingleChildScrollView(
                  child: SelectableText(
                    json,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
