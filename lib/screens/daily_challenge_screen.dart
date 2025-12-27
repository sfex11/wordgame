import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/daily_challenge_service.dart';
import '../models/models.dart';
import '../widgets/puzzle_grid.dart';
import '../widgets/letter_bank.dart';
import '../widgets/hint_buttons.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final DailyChallengeService _dailyService = DailyChallengeService();
  Puzzle? _puzzle;
  int _hintsUsed = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _puzzle = _dailyService.generateDailyChallenge();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9800), // 주황색 (일일 도전 테마)
              Color(0xFFFFE0B2),
            ],
          ),
        ),
        child: SafeArea(
          child: _puzzle == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildTopBar(context),
                    const SizedBox(height: 16),
                    _buildProgress(),
                    const SizedBox(height: 24),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: PuzzleGrid(
                          puzzle: _puzzle!,
                          onCellTap: _onCellTap,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<GameProvider>(
                      builder: (context, provider, _) {
                        return HintButtons(
                          coins: provider.gameState.totalCoins,
                          onRevealLetter: _useHintRevealLetter,
                          onShowMeaning: () {},
                          onShowWrong: _useHintShowWrong,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    LetterBank(
                      letters: _puzzle!.availableLetters,
                      onLetterTap: _onLetterTap,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.today, color: Color(0xFFFF9800), size: 20),
                const SizedBox(width: 8),
                Text(
                  '오늘의 도전 - ${_dailyService.getTodayDateString()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Consumer<GameProvider>(
            builder: (context, provider, _) {
              return Container(
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '단어 ${_puzzle!.completedWordCount}/${_puzzle!.totalWordCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '점수: ${_puzzle!.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _puzzle!.totalWordCount > 0
                ? _puzzle!.completedWordCount / _puzzle!.totalWordCount
                : 0,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  void _onCellTap(int row, int col) {
    if (_puzzle == null || _isCompleted) return;

    final cell = _puzzle!.grid[row][col];

    setState(() {
      if (cell.state == CellState.filled) {
        // 글자 제거
        _puzzle = _removeLetter(_puzzle!, row, col);
      } else if (cell.isSelectable) {
        // 셀 선택
        _puzzle = _puzzle!.copyWith(selectedRow: row, selectedCol: col);
      }
    });
  }

  void _onLetterTap(String letter) {
    if (_puzzle == null || _isCompleted) return;
    if (_puzzle!.selectedRow == null || _puzzle!.selectedCol == null) return;

    setState(() {
      _puzzle = _placeLetter(_puzzle!, letter);

      if (_puzzle!.isCompleted) {
        _isCompleted = true;
        _showCompletionDialog();
      }
    });
  }

  Puzzle _placeLetter(Puzzle puzzle, String letter) {
    final row = puzzle.selectedRow!;
    final col = puzzle.selectedCol!;
    final cell = puzzle.grid[row][col];

    if (!cell.isSelectable) return puzzle;

    List<List<Cell>> newGrid = puzzle.grid
        .map((r) => r.map((c) => c).toList())
        .toList();

    newGrid[row][col] = cell.copyWith(
      userLetter: letter,
      state: CellState.filled,
    );

    List<String> newAvailable = List.from(puzzle.availableLetters);
    newAvailable.remove(letter);

    final (nextRow, nextCol) = _findNextBlank(newGrid, row, col, puzzle.gridSize);
    final (updatedGrid, updatedWords, earnedScore) =
        _checkWordCompletion(newGrid, puzzle.words);
    bool isCompleted = _checkPuzzleCompletion(updatedGrid);

    return puzzle.copyWith(
      grid: updatedGrid,
      words: updatedWords,
      availableLetters: newAvailable,
      selectedRow: nextRow,
      selectedCol: nextCol,
      score: puzzle.score + earnedScore,
      isCompleted: isCompleted,
    );
  }

  Puzzle _removeLetter(Puzzle puzzle, int row, int col) {
    final cell = puzzle.grid[row][col];
    if (cell.state != CellState.filled) return puzzle;

    List<List<Cell>> newGrid = puzzle.grid
        .map((r) => r.map((c) => c).toList())
        .toList();

    final removedLetter = cell.userLetter!;
    newGrid[row][col] = cell.copyWith(
      userLetter: null,
      state: CellState.blank,
    );

    List<String> newAvailable = List.from(puzzle.availableLetters)
      ..add(removedLetter);

    return puzzle.copyWith(
      grid: newGrid,
      availableLetters: newAvailable,
      selectedRow: row,
      selectedCol: col,
    );
  }

  (int?, int?) _findNextBlank(List<List<Cell>> grid, int currentRow, int currentCol, int gridSize) {
    for (int col = currentCol + 1; col < gridSize; col++) {
      if (grid[currentRow][col].isBlank) return (currentRow, col);
    }
    for (int row = currentRow + 1; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col].isBlank) return (row, col);
      }
    }
    for (int row = 0; row <= currentRow; row++) {
      int endCol = row == currentRow ? currentCol : gridSize;
      for (int col = 0; col < endCol; col++) {
        if (grid[row][col].isBlank) return (row, col);
      }
    }
    return (null, null);
  }

  (List<List<Cell>>, List<PlacedWord>, int) _checkWordCompletion(
      List<List<Cell>> grid, List<PlacedWord> words) {
    List<List<Cell>> newGrid = grid.map((r) => r.map((c) => c).toList()).toList();
    List<PlacedWord> newWords = List.from(words);
    int totalScore = 0;

    for (int i = 0; i < words.length; i++) {
      if (words[i].isCompleted) continue;

      final word = words[i];
      bool allFilled = true;
      bool allCorrect = true;

      for (int j = 0; j < word.length; j++) {
        final (row, col) = word.getPosition(j);
        final cell = newGrid[row][col];

        if (cell.state == CellState.blank) {
          allFilled = false;
          break;
        }

        if (cell.state == CellState.filled) {
          if (cell.userLetter != cell.correctLetter) {
            allCorrect = false;
          }
        }
      }

      if (allFilled && allCorrect) {
        newWords[i] = word.copyWith(isCompleted: true);
        totalScore += word.length * 10;

        for (int j = 0; j < word.length; j++) {
          final (row, col) = word.getPosition(j);
          if (newGrid[row][col].state == CellState.filled) {
            newGrid[row][col] = newGrid[row][col].copyWith(state: CellState.correct);
          }
        }
      }
    }

    return (newGrid, newWords, totalScore);
  }

  bool _checkPuzzleCompletion(List<List<Cell>> grid) {
    for (var row in grid) {
      for (var cell in row) {
        if (cell.isBlank) return false;
      }
    }
    return true;
  }

  void _useHintRevealLetter() {
    final provider = context.read<GameProvider>();
    if (provider.gameState.totalCoins < 10) return;

    setState(() {
      for (var row in _puzzle!.grid) {
        for (var cell in row) {
          if (cell.isBlank) {
            List<List<Cell>> newGrid = _puzzle!.grid
                .map((r) => r.map((c) => c).toList())
                .toList();

            newGrid[cell.row][cell.col] = cell.copyWith(state: CellState.hint);

            List<String> newAvailable = List.from(_puzzle!.availableLetters);
            newAvailable.remove(cell.correctLetter);

            _puzzle = _puzzle!.copyWith(
              grid: newGrid,
              availableLetters: newAvailable,
            );

            provider.addCoins(-10);
            _hintsUsed++;
            return;
          }
        }
      }
    });
  }

  void _useHintShowWrong() {
    final provider = context.read<GameProvider>();
    if (provider.gameState.totalCoins < 5) return;

    setState(() {
      List<List<Cell>> newGrid = _puzzle!.grid
          .map((r) => r.map((c) => c).toList())
          .toList();

      for (int row = 0; row < _puzzle!.gridSize; row++) {
        for (int col = 0; col < _puzzle!.gridSize; col++) {
          final cell = newGrid[row][col];
          if (cell.state == CellState.filled &&
              cell.userLetter != cell.correctLetter) {
            newGrid[row][col] = cell.copyWith(state: CellState.wrong);
          }
        }
      }

      _puzzle = _puzzle!.copyWith(grid: newGrid);
      provider.addCoins(-5);
      _hintsUsed++;
    });
  }

  void _showCompletionDialog() {
    final reward = _dailyService.calculateDailyReward(_puzzle!.score);
    final provider = context.read<GameProvider>();
    provider.addCoins(reward);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Color(0xFFFF9800)),
            SizedBox(width: 8),
            Text('일일 도전 완료!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('점수: ${_puzzle!.score}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('보상: '),
                const Icon(Icons.monetization_on, color: Color(0xFFFFD700)),
                Text(
                  '+$reward',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
