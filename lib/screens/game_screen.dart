import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/models.dart';
import '../widgets/puzzle_grid.dart';
import '../widgets/letter_bank.dart';
import '../widgets/hint_buttons.dart';
import '../widgets/meaning_popup.dart';
import 'level_complete_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _dialogShown = false;

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
              if (puzzle.isCompleted && !_dialogShown) {
                _dialogShown = true;
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
                    onShowMeaning: () => _showMeaningHint(context, provider, puzzle),
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

  void _showMeaningHint(BuildContext context, GameProvider provider, Puzzle puzzle) {
    // 선택된 셀이 있으면 해당 단어의 뜻 표시
    if (puzzle.selectedRow != null && puzzle.selectedCol != null) {
      final cell = puzzle.grid[puzzle.selectedRow!][puzzle.selectedCol!];
      if (cell.wordIndices.isNotEmpty) {
        final wordIndex = cell.wordIndices.first;
        final word = puzzle.words[wordIndex];

        if (provider.gameState.totalCoins >= 5) {
          provider.addCoins(-5);
          MeaningPopup.show(context, word.text, word.meaning);
        } else {
          _showInsufficientCoinsDialog(context);
        }
        return;
      }
    }

    // 선택된 셀이 없으면 미완성 단어 중 하나의 뜻 표시
    for (final word in puzzle.words) {
      if (!word.isCompleted) {
        if (provider.gameState.totalCoins >= 5) {
          provider.addCoins(-5);
          MeaningPopup.show(context, '???', word.meaning);
        } else {
          _showInsufficientCoinsDialog(context);
        }
        return;
      }
    }
  }

  void _showInsufficientCoinsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.monetization_on, color: Colors.grey),
            SizedBox(width: 8),
            Text('코인 부족'),
          ],
        ),
        content: const Text('힌트를 사용하려면 코인이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
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
