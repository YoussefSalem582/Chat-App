import 'package:flutter/material.dart';

class AdminTabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final int index;
  final int selectedIndex;
  final bool isDarkMode;
  final VoidCallback onTap;

  const AdminTabButton({
    super.key,
    required this.title,
    required this.icon,
    required this.index,
    required this.selectedIndex,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF667eea)
                  : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
