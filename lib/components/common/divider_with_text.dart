import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final double thickness;
  final Color? color;
  final Color? textColor;

  const DividerWithText({
    super.key,
    required this.text,
    this.thickness = 1,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        color ?? (isDark ? Colors.grey.shade700 : Colors.grey.shade300);
    final textStyle = TextStyle(
      color:
          textColor ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: thickness, color: dividerColor)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(text, style: textStyle),
          ),
          Expanded(child: Divider(thickness: thickness, color: dividerColor)),
        ],
      ),
    );
  }
}
