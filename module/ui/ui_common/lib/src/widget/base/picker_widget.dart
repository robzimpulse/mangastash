import 'package:flutter/material.dart';
import 'package:intersperse/intersperse.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PickerWidget extends StatefulWidget {
  const PickerWidget({
    super.key,
    this.controller,
    this.options,
    this.selected,
    this.onSelected,
  });

  final ScrollController? controller;
  final List<String>? options;
  final String? selected;
  final ValueSetter<String>? onSelected;

  @override
  State<PickerWidget> createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<PickerWidget> {
  String keyword = '';
  List<String> filtered = [];

  @override
  void initState() {
    super.initState();
    filtered = [...?widget.options];
  }

  void _filter(String value) {
    setState(() {
      keyword = value;
      filtered = value.isEmpty
          ? [...?widget.options]
          : [
              ...(widget.options ?? []).where(
                (e) => e.toLowerCase().contains(value.toLowerCase()),
              ),
            ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.controller,
      slivers: [
        SliverPinnedHeader(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                contentPadding: EdgeInsets.all(8),
              ),
              onChanged: _filter,
              onSubmitted: _filter,
            ),
          ),
        ),
        ...filtered
            .map<Widget>(
              (e) => ListTile(
                title: Text(e),
                trailing: Visibility(
                  visible: e == widget.selected,
                  child: const Icon(Icons.check),
                ),
                onTap: () => widget.onSelected?.call(e),
              ),
            )
            .intersperse(const Divider(height: 1, thickness: 1))
            .map((e) => SliverToBoxAdapter(child: e)),
      ],
    );
  }
}
