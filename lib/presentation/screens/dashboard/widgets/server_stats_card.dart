import 'package:flutter/material.dart';

class ServerStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? subtitle;
  final double? progress;

  const ServerStatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.subtitle,
    this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Factory per creare una card di statistiche CPU
  factory ServerStatsCard.cpu(int percentage) {
    return ServerStatsCard(
      title: 'CPU Usage',
      value: '$percentage%',
      icon: Icons.memory,
      progress: percentage / 100,
    );
  }

  /// Factory per creare una card di statistiche RAM
  factory ServerStatsCard.ram(int percentage) {
    return ServerStatsCard(
      title: 'Memory Usage',
      value: '$percentage%',
      icon: Icons.sd_card,
      progress: percentage / 100,
    );
  }

  /// Factory per creare una card di statistiche Storage
  factory ServerStatsCard.storage(int percentage) {
    return ServerStatsCard(
      title: 'Storage',
      value: '$percentage%',
      icon: Icons.storage,
      progress: percentage / 100,
    );
  }

  /// Factory per creare una card di statistiche Players
  factory ServerStatsCard.players(int current, int max, String uptime) {
    return ServerStatsCard(
      title: 'Players',
      value: '$current/$max',
      subtitle: 'Uptime: $uptime',
      icon: Icons.people,
    );
  }
}