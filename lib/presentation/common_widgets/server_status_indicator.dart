import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

class ServerStatusIndicator extends StatelessWidget {
  final bool isRunning;
  final bool isLarge;

  const ServerStatusIndicator({
    Key? key,
    required this.isRunning,
    this.isLarge = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12.0 : 8.0,
        vertical: isLarge ? 6.0 : 2.0,
      ),
      decoration: BoxDecoration(
        color: isRunning
            ? AppTheme.onlineColor.withOpacity(0.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isRunning ? 'online' : 'offline',
        style: TextStyle(
          color: isRunning ? AppTheme.onlineColor : AppTheme.offlineColor,
          fontWeight: FontWeight.w500,
          fontSize: isLarge ? 14.0 : 12.0,
        ),
      ),
    );
  }
}