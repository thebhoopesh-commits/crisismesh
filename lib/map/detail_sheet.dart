import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'help_request.dart';

class DetailSheet extends StatelessWidget {
  final HelpRequest request;

  const DetailSheet({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    Color color;
    String badgeText;
    switch (request.severity) {
      case Severity.critical: color = AppColors.critical; badgeText = 'CRITICAL'; break;
      case Severity.urgent: color = AppColors.urgent; badgeText = 'URGENT'; break;
      case Severity.stable: color = AppColors.stable; badgeText = 'STABLE'; break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  request.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.condition,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Stat(icon: Icons.directions_walk, label: request.distance),
                _Stat(icon: Icons.schedule, label: request.reportedAgo),
                _Stat(icon: Icons.hub, label: '${request.hops} hops'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.route, color: Colors.white),
            label: const Text('Show route to them', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
