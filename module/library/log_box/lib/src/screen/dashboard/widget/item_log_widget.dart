import 'package:flutter/material.dart';

import '../../../model/log_model.dart';

class ItemLogWidget extends StatelessWidget {

  final LogModel data;

  final VoidCallback? onTap;

  const ItemLogWidget({super.key, required this.data, this.onTap});

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
                _buildLogInfo(context),
                // _buildStatusCode(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // final String message;
  // final DateTime? time;
  // final int? sequenceNumber;
  // final int level;
  // final String? name;
  // final Zone? zone;
  // final Object? error;
  // final StackTrace? stackTrace;

  Widget _buildLogInfo(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '[${data.name ?? 'Unknown'}]',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              data.message,
              style: Theme.of(context).textTheme.labelMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(color: Colors.grey),
            Text(
              data.time?.toIso8601String() ?? 'n/a',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

}