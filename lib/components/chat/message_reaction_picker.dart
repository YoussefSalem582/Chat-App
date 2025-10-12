import 'package:flutter/material.dart';

class MessageReactionPicker extends StatelessWidget {
  final Function(String) onReactionSelected;

  const MessageReactionPicker({super.key, required this.onReactionSelected});

  static const List<String> reactions = ['❤️', '👍', '😂', '😮', '😢', '🔥'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            reactions.map((reaction) {
              return GestureDetector(
                onTap: () => onReactionSelected(reaction),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(reaction, style: const TextStyle(fontSize: 28)),
                ),
              );
            }).toList(),
      ),
    );
  }
}
