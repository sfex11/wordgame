import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('레벨 선택'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Consumer<GameProvider>(
          builder: (context, provider, _) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 50,
              itemBuilder: (context, index) {
                final level = index + 1;
                final isUnlocked = provider.gameState.isLevelUnlocked(level);
                final isCompleted = provider.gameState.isLevelCompleted(level);

                return _buildLevelButton(
                  context,
                  level,
                  isUnlocked,
                  isCompleted,
                  provider,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildLevelButton(
    BuildContext context,
    int level,
    bool isUnlocked,
    bool isCompleted,
    GameProvider provider,
  ) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    if (isCompleted) {
      backgroundColor = const Color(0xFF4CAF50);
      textColor = Colors.white;
      icon = Icons.check;
    } else if (isUnlocked) {
      backgroundColor = Colors.white;
      textColor = Colors.black87;
    } else {
      backgroundColor = Colors.grey[300]!;
      textColor = Colors.grey[500]!;
      icon = Icons.lock;
    }

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              provider.startLevel(level);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen()),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: textColor, size: 24)
              : Text(
                  '$level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}
