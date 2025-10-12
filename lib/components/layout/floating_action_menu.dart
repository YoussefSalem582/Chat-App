import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingActionMenu extends StatefulWidget {
  final List<FloatingActionMenuItem> items;
  final IconData mainIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FloatingActionMenu({
    super.key,
    required this.items,
    this.mainIcon = Icons.add,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Menu items
        ...List.generate(widget.items.length, (index) {
          final item = widget.items[widget.items.length - 1 - index];
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final slideValue = _controller.value * (index + 1) * 60.0;
              return Transform.translate(
                offset: Offset(0, -slideValue),
                child: Opacity(opacity: _controller.value, child: child),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  if (item.label != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        item.label!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  // Button
                  FloatingActionButton(
                    heroTag: 'fab_${item.label}_$index',
                    onPressed: () {
                      _toggle();
                      item.onPressed();
                    },
                    backgroundColor:
                        item.backgroundColor ??
                        (isDark ? Colors.blue.shade700 : Colors.blue.shade500),
                    mini: true,
                    child: Icon(
                      item.icon,
                      color: item.foregroundColor ?? Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Main button
        FloatingActionButton(
          heroTag: 'fab_main',
          onPressed: _toggle,
          backgroundColor:
              widget.backgroundColor ??
              (isDark ? Colors.blue.shade700 : Colors.blue.shade500),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * math.pi / 4,
                child: Icon(
                  _isOpen ? Icons.close : widget.mainIcon,
                  color: widget.foregroundColor ?? Colors.white,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FloatingActionMenuItem {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  FloatingActionMenuItem({
    required this.icon,
    this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });
}
