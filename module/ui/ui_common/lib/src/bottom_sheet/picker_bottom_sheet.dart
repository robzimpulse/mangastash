import 'package:flutter/material.dart';

import '../../src/extension/bottom_sheet_extension.dart';

class PickerBottomSheet extends StatefulWidget {
  const PickerBottomSheet({super.key, required this.names});

  final List<String> names;

  @override
  State<PickerBottomSheet> createState() => _PickerBottomSheetState();
}

class _PickerBottomSheetState extends State<PickerBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      builder: (context, controller) => ListView.separated(
        controller: controller,
        itemBuilder: (context, index) => ListTile(
          title: Text(widget.names[index]),
          onTap: () => context.dismissSheet(result: widget.names[index]),
        ),
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
        ),
        itemCount: widget.names.length,
      ),
    );
  }
}
