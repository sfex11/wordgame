import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/models.dart';
import '../widgets/puzzle_grid.dart';
import '../widgets/letter_bank.dart';
import '../widgets/hint_buttons.dart';
import 'level_complete_dialog.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB),
              Color(0xFFB3E5FC),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, provider, _) {
              final puzzle = provider.currentPuzzle;

              if (puzzle == null) {
                return const Center(child: CircularProgressIndicator());
              }

              // 레벨 완료 체크
              if (puzzle.isCompleted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showLevelCompleteDialog(context, puzzle);
                });
              }

              return Column(
                children: [
                  // 상단 바
                  _buildTopBar(context, provider, puzzle),

                  const SizedBox(height: 16),

                  // 진행 상황
                  _buildProgress(puzzle),

                  const SizedBox(height: 24),

                  // 퍼즐 격자
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: PuzzleGrid(
                        puzzle: puzzle,
                        onCellTap: (row, col) {
                          provider.selectCell(row, col);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 힌트 버튼
                  HintButtons(
                    coins: provider.gameState.totalCoins,
                    onRevealLetter: () => provider.useHintRevealLetter(),
                    onShowMeaning: () {
                      // TODO: 뜻풀이 팝업
                    },
                    onShowWrong: () => provider.useHintShowWrong(),
                  ),

                  const SizedBox(height: 16),

                  // 글자 뱅크
                  LetterBank(
                    letters: puzzle.availableLetters,
                    onLetterTap: (letter) {
                      provider.placeLetter(letter);
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, GameProvider provider, Puzzle puzzle) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 뒤로가기
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          // 레벨 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '레벨 ${puzzle.level}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Spacer(),

          // 코인 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 20),
                const SizedBox(width: 4),
                Text(
                  '${provider.gameState.totalCoins}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(Puzzle puzzle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '단어 ${puzzle.completedWordCount}/${puzzle.totalWordCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '점수: ${puzzle.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: puzzle.totalWordCount > 0
                ? puzzle.completedWordCount / puzzle.totalWordCount
                : 0,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  void _showLevelCompleteDialog(BuildContext context, Puzzle puzzle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelCompleteDialog(puzzle: puzzle),
    );
  }
}
