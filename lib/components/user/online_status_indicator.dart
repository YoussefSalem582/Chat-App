import 'package:flutter/material.dart';

class OnlineStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;
  final bool showPulse;

  const OnlineStatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 10,
    this.showPulse = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.shade400 : Colors.grey.shade400,
        shape: BoxShape.circle,
        boxShadow:
            isOnline && showPulse
                ? [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
                : null,
      ),
    );
  }
}

class OnlineStatusText extends StatelessWidget {
  final bool isOnline;
  final String? lastSeenText;

  const OnlineStatusText({
    super.key,
    required this.isOnline,
    this.lastSeenText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OnlineStatusIndicator(isOnline: isOnline, size: 8),
        const SizedBox(width: 6),
        Text(
          isOnline ? 'Active now' : (lastSeenText ?? 'Offline'),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
