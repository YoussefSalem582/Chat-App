import 'package:flutter/material.dart';
import 'profile_stat_card.dart';

class ProfileStatsSection extends StatelessWidget {
  final Map<String, int> stats;
  final bool isDark;

  const ProfileStatsSection({
    super.key,
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ProfileStatCard(
              icon: Icons.chat_bubble_outline,
              value: stats['messages'].toString(),
              label: 'Messages',
              color: Colors.blue,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProfileStatCard(
              icon: Icons.people_outline,
              value: stats['contacts'].toString(),
              label: 'Contacts',
              color: Colors.green,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProfileStatCard(
              icon: Icons.group_outlined,
              value: stats['groups'].toString(),
              label: 'Groups',
              color: Colors.purple,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}
