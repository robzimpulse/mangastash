import 'package:flutter/material.dart';

import '../../../common/extension.dart';
import '../../../common/helper.dart';

class ItemColumn extends StatelessWidget {
  final String? name;
  final String? value;
  final bool showCopyButton;
  final bool isImage;

  const ItemColumn({
    super.key,
    this.name,
    this.value,
    this.showCopyButton = true,
    this.isImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    if (value == null) {
      return const SizedBox();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name!, style: const TextStyle(fontWeight: FontWeight.bold)),
            Visibility(
              visible: showCopyButton,
              child: IconButton(
                icon: const Icon(
                  Icons.copy,
                  size: 16,
                  color: Colors.grey,
                ),
                onPressed: () {
                  Helper.copyToClipboard(
                    text: value.isJson ? value.prettify : value,
                    context: context,
                  );
                },
              ),
            ),
          ],
        ),
        if (isImage)
          const Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Placeholder(),
            ),
          ),
        if (!isImage)
          SizedBox(
            width: double.infinity,
            child: Card(
              elevation: 0,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  value.isJson ? value.prettify : value,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.black),
                ),
              ),
            ),
          ),
      ],
    );
  }
}