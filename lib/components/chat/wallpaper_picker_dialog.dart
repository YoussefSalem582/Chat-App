import 'package:flutter/material.dart';

class WallpaperPickerDialog extends StatelessWidget {
  final Color? currentColor;
  final Function(Color) onColorSelected;

  const WallpaperPickerDialog({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Solid colors - Light pastels
    final solidColors = [
      Colors.grey.shade100,
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.purple.shade50,
      Colors.pink.shade50,
      Colors.orange.shade50,
      Colors.teal.shade50,
      Colors.indigo.shade50,
      Colors.cyan.shade50,
      Colors.amber.shade50,
      Colors.lime.shade50,
      Colors.deepPurple.shade50,
      // Medium tones
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.purple.shade100,
      Colors.pink.shade100,
      Colors.orange.shade100,
      Colors.teal.shade100,
      Colors.indigo.shade100,
      Colors.cyan.shade100,
      Colors.amber.shade100,
      Colors.lime.shade100,
      Colors.deepPurple.shade100,
      Colors.red.shade100,
      // Darker tones for variety
      Colors.blue.shade200,
      Colors.green.shade200,
      Colors.purple.shade200,
      Colors.pink.shade200,
      Colors.orange.shade200,
      Colors.teal.shade200,
    ];

    return AlertDialog(
      title: const Text(
        'Choose Wallpaper',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Solid Colors',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: solidColors.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildClearOption(context);
                  }
                  final color = solidColors[index - 1];
                  return _buildColorOption(context, color);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Gradient Wallpapers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: _gradients.length,
                itemBuilder: (context, index) {
                  final gradient = _gradients[index];
                  return _buildGradientOption(context, gradient);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  // Beautiful gradient combinations
  static final List<LinearGradient> _gradients = [
    // Sunset
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
    ),
    // Ocean
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF4E65FF), Color(0xFF92EFFD)],
    ),
    // Purple Dream
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFA8E6CF), Color(0xFFDCEDC8)],
    ),
    // Pink Lemonade
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFA3D7), Color(0xFFFFE5B4)],
    ),
    // Mint Fresh
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
    ),
    // Peach
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFCCBC), Color(0xFFFF8A80)],
    ),
    // Lavender
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFE1BEE7), Color(0xFFCE93D8)],
    ),
    // Sky Blue
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFB3E5FC), Color(0xFF81D4FA)],
    ),
    // Lime Green
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF0F4C3), Color(0xFFDCE775)],
    ),
    // Coral
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFCDD2), Color(0xFFF48FB1)],
    ),
    // Teal Wave
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF80CBC4), Color(0xFF4DB6AC)],
    ),
    // Indigo Night
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF9FA8DA), Color(0xFF7986CB)],
    ),
    // Amber Gold
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFE082), Color(0xFFFFD54F)],
    ),
    // Rose
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF8BBD0), Color(0xFFF06292)],
    ),
    // Cool Breeze
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFB2EBF2), Color(0xFF80DEEA)],
    ),
    // Purple Haze
    const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
    ),
  ];

  Widget _buildClearOption(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onColorSelected(Colors.transparent);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.clear, color: Colors.grey.shade600, size: 24),
            const SizedBox(height: 4),
            Text(
              'Clear',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, Color color) {
    final isSelected = currentColor == color;

    return GestureDetector(
      onTap: () {
        onColorSelected(color);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                  : null,
        ),
        child:
            isSelected
                ? const Icon(Icons.check, color: Colors.blue, size: 24)
                : null,
      ),
    );
  }

  Widget _buildGradientOption(BuildContext context, LinearGradient gradient) {
    return GestureDetector(
      onTap: () {
        // Use the first color of the gradient as the wallpaper color
        onColorSelected(gradient.colors[0]);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}
