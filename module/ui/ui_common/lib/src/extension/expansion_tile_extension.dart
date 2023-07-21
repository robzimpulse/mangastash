import 'package:flutter/material.dart';

extension ExpansionTileNoDividerExtension on ExpansionTile {
  Widget divider({required BuildContext context, required bool visible}) {
    if (visible) return this;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: this,
    );
  }
}