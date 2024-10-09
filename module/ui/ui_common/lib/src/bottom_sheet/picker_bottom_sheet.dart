import 'package:core_route/core_route.dart';
import 'package:flutter/material.dart';

class PickerBottomSheet extends StatelessWidget {
  const PickerBottomSheet({super.key, required this.names, this.selectedName});

  final List<String> names;

  final String? selectedName;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) => ListTile(
        title: Text(names[index]),
        trailing: Visibility(
          visible: names[index] == selectedName,
          child: const Icon(Icons.check),
        ),
        onTap: () => context.pop(names[index]),
      ),
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 1,
      ),
      itemCount: names.length,
    );
  }
}
