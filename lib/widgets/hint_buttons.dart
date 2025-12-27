import 'package:flutter/material.dart';

class HintButtons extends StatelessWidget {
  final int coins;
  final VoidCallback onRevealLetter;
  final VoidCallback onShowMeaning;
  final VoidCallback onShowWrong;

  const HintButtons({
    super.key,
    required this.coins,
    required this.onRevealLetter,
    required this.onShowMeaning,
    required this.onShowWrong,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHintButton(
            icon: Icons.lightbulb_outline,
            label: '글자',
            cost: 10,
            enabled: coins >= 10,
            onTap: onRevealLetter,
          ),
          const SizedBox(width: 16),
          _buildHintButton(
            icon: Icons.help_outline,
            label: '뜻풀이',
            cost: 5,
            enabled: coins >= 5,
            onTap: onShowMeaning,
          ),
          const SizedBox(width: 16),
          _buildHintButton(
            icon: Icons.search,
            label: '오답',
            cost: 5,
            enabled: coins >= 5,
            onTap: onShowWrong,
          ),
        ],
      ),
    );
  }

  Widget _buildHintButton({
    required IconData icon,
    required String label,
    required int cost,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: enabled ? const Color(0xFF4CAF50) : Colors.grey,
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: enabled ? Colors.black87 : Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 12,
                      color: enabled ? const Color(0xFFFFD700) : Colors.grey,
                    ),
                    Text(
                      '$cost',
                      style: TextStyle(
                        fontSize: 10,
                        color: enabled ? Colors.black54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
