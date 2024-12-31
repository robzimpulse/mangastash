import 'package:flutter/material.dart';

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
                _buildStatusCode(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestInfo(BuildContext context) {
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
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.endpoint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            Text(
              data.uri,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const Divider(color: Colors.grey),
            Row(
              children: [
                Text(
                  data.request?.time != null
                      ? _formatTime(data.request!.time)
                      : 'n/a',
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

  Widget _buildStatusCode() {
    final int statusCode = data.response?.status ?? 0;
    Color statusColor;
    if (statusCode >= 200 && statusCode < 300) {
      statusColor = Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      statusColor = Colors.blue;
    } else if (statusCode >= 400 && statusCode < 500) {
      statusColor = Colors.orange;
    } else if (statusCode >= 500 && statusCode < 600) {
      statusColor = Colors.red;
    } else {
      return const DotIndicatorWidget(
        dotColor: Colors.grey,
        dotSize: 8.0,
        animationDuration: Duration(milliseconds: 1000),
      );
    }

    return Text(
      statusCode.toString(),
      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
    );
  }

  String _formatTime(DateTime time) {
    return '${_formatTimeUnit(time.hour)}:${_formatTimeUnit(time.minute)}:${_formatTimeUnit(time.second)}';
  }

  String _formatTimeUnit(int unit) {
    return unit.toString().padLeft(2, '0');
  }
}
