import 'package:flutter/material.dart';

class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int characterCount;
  final int maxCharacters;
  final VoidCallback onSend;
  final VoidCallback onAttachment;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.characterCount,
    required this.maxCharacters,
    required this.onSend,
    required this.onAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Character counter
            if (characterCount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$characterCount/$maxCharacters',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            characterCount > maxCharacters
                                ? Colors.red
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            // Input row
            Row(
              children: [
                // Attachment button
                _buildAttachmentButton(context),
                const SizedBox(width: 8),
                // Text input
                Expanded(child: _buildTextField(context, isDark)),
                const SizedBox(width: 8),
                // Send button
                _buildSendButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onAttachment,
        icon: Icon(Icons.add, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.grey.shade800.withOpacity(0.5)
                : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: 'Type a message...',
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSend = characterCount > 0 && characterCount <= maxCharacters;

    return Container(
      decoration: BoxDecoration(
        gradient:
            canSend
                ? LinearGradient(
                  colors:
                      isDark
                          ? [Colors.blue.shade700, Colors.blue.shade600]
                          : [Colors.blue.shade500, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : null,
        color: canSend ? null : Colors.grey.shade400,
        shape: BoxShape.circle,
        boxShadow:
            canSend
                ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: IconButton(
        onPressed: canSend ? onSend : null,
        icon: const Icon(Icons.send_rounded, color: Colors.white),
        iconSize: 22,
      ),
    );
  }
}
