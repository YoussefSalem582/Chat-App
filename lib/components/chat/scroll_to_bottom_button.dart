import 'package:flutter/material.dart';

class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScrollToBottomButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      right: 16,
      child: FloatingActionButton.small(
        onPressed: onPressed,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
      ),
    );
  }
}
