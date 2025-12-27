import 'package:equatable/equatable.dart';
import 'cell.dart';
import 'placed_word.dart';

/// 퍼즐 모델 (한 레벨의 전체 퍼즐 상태)
class Puzzle extends Equatable {
  final int level;
  final int gridSize;
  final List<List<Cell>> grid;
  final List<PlacedWord> words;
  final List<String> availableLetters;  // 하단에 표시될 글자들
  final int? selectedRow;
  final int? selectedCol;
  final int score;
  final bool isCompleted;

  const Puzzle({
    required this.level,
    required this.gridSize,
    required this.grid,
    required this.words,
    required this.availableLetters,
    this.selectedRow,
    this.selectedCol,
    this.score = 0,
    this.isCompleted = false,
  });

  /// 선택된 셀
  Cell? get selectedCell {
    if (selectedRow == null || selectedCol == null) return null;
    return grid[selectedRow!][selectedCol!];
  }

  /// 완성된 단어 수
  int get completedWordCount => words.where((w) => w.isCompleted).length;

  /// 전체 단어 수
  int get totalWordCount => words.length;

  /// 남은 빈칸 수
  int get remainingBlanks {
    int count = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell.isBlank) count++;
      }
    }
    return count;
  }

  Puzzle copyWith({
    int? level,
    int? gridSize,
    List<List<Cell>>? grid,
    List<PlacedWord>? words,
    List<String>? availableLetters,
    int? selectedRow,
    int? selectedCol,
    int? score,
    bool? isCompleted,
    bool clearSelection = false,
  }) {
    return Puzzle(
      level: level ?? this.level,
      gridSize: gridSize ?? this.gridSize,
      grid: grid ?? this.grid,
      words: words ?? this.words,
      availableLetters: availableLetters ?? this.availableLetters,
      selectedRow: clearSelection ? null : (selectedRow ?? this.selectedRow),
      selectedCol: clearSelection ? null : (selectedCol ?? this.selectedCol),
      score: score ?? this.score,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        level,
        gridSize,
        grid,
        words,
        availableLetters,
        selectedRow,
        selectedCol,
        score,
        isCompleted,
      ];
}
