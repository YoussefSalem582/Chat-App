import 'package:flutter/material.dart';

class SelectionHeader extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;

  const SelectionHeader({
    super.key,
    required this.selectedCount,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Text(
            '$selectedCount selected',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const Spacer(),
          TextButton(onPressed: onCancel, child: const Text('Cancel')),
        ],
      ),
    );
  }
}
