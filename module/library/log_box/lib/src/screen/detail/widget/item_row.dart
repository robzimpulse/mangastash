import 'package:flutter/material.dart';

class ItemRow extends StatelessWidget {
  final String name;
  final String? value;

  const ItemRow({
    required this.name,
    this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 5),
        ),
        Flexible(
          child: value != null ? Text(value!) : const SizedBox(),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 18),
        ),
      ],
    );
  }
}
