import 'package:flutter/material.dart';

import '../../../common/extension.dart';
import '../../../common/helper.dart';
import '../../../model/http_activity_model.dart';
import 'dot_indicator_widget.dart';

class ItemResponseWidget extends StatelessWidget {
  final HttpActivityModel data;
  final VoidCallback? onTap;

  const ItemResponseWidget({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      width: double.infinity,
      child: Card(
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        // color: Colors.white,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildRequestInfo(context),
                _buildStatusCode(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  data.method,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.endpoint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            Text(
              data.uri,
              style: theme.textTheme.labelMedium,
            ),
            const Divider(color: Colors.grey),
            Row(
              children: [
                Text(
                  data.request?.time.time ?? 'n/a',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  '${Helper.formatBytes(data.request?.size ?? 0)} / '
                  '${Helper.formatBytes(data.response?.size ?? 0)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  Helper.formatTime(data.duration),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCode(BuildContext context) {
    final theme = Theme.of(context);

    if (data.error != null) {
      return Text(
        'Error',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final code = data.response?.status;

    if (code == null) {
      return const DotIndicatorWidget(
        dotColor: Colors.grey,
        dotSize: 8.0,
        animationDuration: Duration(milliseconds: 1000),
      );
    }

    return Text(
      '$code',
      style: theme.textTheme.labelSmall?.copyWith(
        color: _statusColor(code),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Color _statusColor(int code) {
    if (code >= 200 && code < 300) {
      return Colors.green;
    } else if (code >= 300 && code < 400) {
      return Colors.blue;
    } else if (code >= 400 && code < 500) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
