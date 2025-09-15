import 'package:flutter/material.dart';

// Simple Notification Badge Widget - Easy to understand for beginners
class NotificationBadge extends StatelessWidget {
  final String count;
  final double? size;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationBadge({
    super.key,
    required this.count,
    this.size,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show badge if count is empty or "0"
    if (count.isEmpty || count == '0') {
      return const SizedBox.shrink();
    }

    final badgeSize = size ?? 20.0;
    final bgColor = backgroundColor ?? Colors.red;
    final txtColor = textColor ?? Colors.white;

    return Container(
      constraints: BoxConstraints(
        minWidth: badgeSize,
        minHeight: badgeSize,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(badgeSize / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count,
          style: TextStyle(
            color: txtColor,
            fontSize: badgeSize * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Simple Dot Badge Widget - Shows just a dot for notifications
class DotBadge extends StatelessWidget {
  final bool show;
  final double? size;
  final Color? color;

  const DotBadge({
    super.key,
    required this.show,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return const SizedBox.shrink();
    }

    final dotSize = size ?? 8.0;
    final dotColor = color ?? Colors.red;

    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
