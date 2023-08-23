import 'package:flutter/material.dart';

class GappedToggleButtonWidget extends StatelessWidget {
  const GappedToggleButtonWidget({
    super.key,
    this.backgroundColor,
    required this.icons,
    required this.labels,
    required this.isSelected,
    this.onPressed,
    this.selectedColor,
    this.unselectedColor,
    this.foregroundColor,
    this.size,
  })  : assert(icons.length == labels.length),
        assert(icons.length == isSelected.length);

  final Color? backgroundColor;

  final Color? foregroundColor;

  final Color? selectedColor;

  final Color? unselectedColor;

  final List<Icon> icons;

  final List<String> labels;

  final List<bool> isSelected;

  final void Function(int index)? onPressed;

  final Size? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size?.height,
      width: size?.width,
      color: backgroundColor,
      padding: const EdgeInsets.all(8),
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: BorderSide(width: 1, color: _color(index)),
            foregroundColor: foregroundColor,
            backgroundColor: foregroundColor?.withOpacity(0.2),
          ),
          icon: icons[index],
          label: Text(labels[index]),
          onPressed: () => onPressed?.call(index),
        ),
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: icons.length,
      ),
    );
  }

  Color _color(int index) {
    final color = isSelected[index] == true ? selectedColor : unselectedColor;
    return color ?? Colors.white;
  }
}
