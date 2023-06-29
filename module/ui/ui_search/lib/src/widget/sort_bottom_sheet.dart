import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text('Modal BottomSheet'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  child: const Text('Reset'),
                  onPressed: () => context.pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  child: const Text('Apply'),
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

}