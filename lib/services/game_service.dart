import '../models/models.dart';
import 'puzzle_generator.dart';

/// 게임 로직 서비스
class GameService {
  final PuzzleGenerator _generator = PuzzleGenerator();

  /// 새 퍼즐 시작
  Puzzle startLevel(int level) {
    return _generator.generatePuzzle(level);
  }

  /// 설정으로 퍼즐 시작
  Puzzle startLevelWithConfig(
    int level,
    int wordCount,
    int gridSize,
    int hintPercent,
  ) {
    return _generator.generatePuzzleWithConfig(
      level,
      wordCount,
      gridSize,
      hintPercent,
    );
  }

  /// 셀 선택
  Puzzle selectCell(Puzzle puzzle, int row, int col) {
    final cell = puzzle.grid[row][col];
    if (!cell.isSelectable) return puzzle;

    return puzzle.copyWith(
      selectedRow: row,
      selectedCol: col,
    );
  }

  /// 글자 배치
  Puzzle placeLetter(Puzzle puzzle, String letter) {
    if (puzzle.selectedRow == null || puzzle.selectedCol == null) {
      return puzzle;
    }

    final row = puzzle.selectedRow!;
    final col = puzzle.selectedCol!;
    final cell = puzzle.grid[row][col];

    if (!cell.isSelectable) return puzzle;

    // 격자 업데이트
    List<List<Cell>> newGrid = puzzle.grid
        .map((r) => r.map((c) => c).toList())
        .toList();

    newGrid[row][col] = cell.copyWith(
      userLetter: letter,
      state: CellState.filled,
    );

    // 사용 가능한 글자에서 제거
    List<String> newAvailable = List.from(puzzle.availableLetters);
    newAvailable.remove(letter);

    // 다음 빈칸으로 이동
    final (nextRow, nextCol) = _findNextBlank(newGrid, row, col, puzzle.gridSize);

    // 단어 완성 체크
    final (updatedGrid, updatedWords, earnedScore) =
        _checkWordCompletion(newGrid, puzzle.words);

    // 전체 완료 체크
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

  /// 글자 제거 (빈칸 터치 시)
  Puzzle removeLetter(Puzzle puzzle, int row, int col) {
    final cell = puzzle.grid[row][col];
    if (cell.state != CellState.filled) return puzzle;

    // 격자 업데이트
    List<List<Cell>> newGrid = puzzle.grid
        .map((r) => r.map((c) => c).toList())
        .toList();

    final removedLetter = cell.userLetter!;
    newGrid[row][col] = cell.copyWith(
      userLetter: null,
      state: CellState.blank,
    );

    // 사용 가능한 글자에 추가
    List<String> newAvailable = List.from(puzzle.availableLetters)
      ..add(removedLetter);

    return puzzle.copyWith(
      grid: newGrid,
      availableLetters: newAvailable,
      selectedRow: row,
      selectedCol: col,
    );
  }

  /// 다음 빈칸 찾기
  (int?, int?) _findNextBlank(
      List<List<Cell>> grid, int currentRow, int currentCol, int gridSize) {
    // 현재 행에서 오른쪽으로
    for (int col = currentCol + 1; col < gridSize; col++) {
      if (grid[currentRow][col].isBlank) {
        return (currentRow, col);
      }
    }

    // 다음 행들
    for (int row = currentRow + 1; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col].isBlank) {
          return (row, col);
        }
      }
    }

    // 처음부터 현재 위치까지
    for (int row = 0; row <= currentRow; row++) {
      int startCol = row == currentRow ? 0 : 0;
      int endCol = row == currentRow ? currentCol : gridSize;
      for (int col = startCol; col < endCol; col++) {
        if (grid[row][col].isBlank) {
          return (row, col);
        }
      }
    }

    return (null, null);
  }

  /// 단어 완성 체크
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

      // 모든 칸이 채워졌는지 확인
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

      // 모든 칸이 채워졌고 정답인 경우
      if (allFilled && allCorrect) {
        // 단어 완성 처리
        newWords[i] = word.copyWith(isCompleted: true);
        totalScore += word.length * 10;

        // 셀 상태를 correct로 변경
        for (int j = 0; j < word.length; j++) {
          final (row, col) = word.getPosition(j);
          if (newGrid[row][col].state == CellState.filled) {
            newGrid[row][col] = newGrid[row][col].copyWith(
              state: CellState.correct,
            );
          }
        }
      }
    }

    return (newGrid, newWords, totalScore);
  }

  /// 퍼즐 완료 체크
  bool _checkPuzzleCompletion(List<List<Cell>> grid) {
    for (var row in grid) {
      for (var cell in row) {
        if (cell.isBlank) return false;
      }
    }
    return true;
  }

  /// 힌트 사용: 글자 하나 공개
  Puzzle useHintRevealLetter(Puzzle puzzle) {
    // 빈칸 중 하나를 찾아 정답 공개
    for (var row in puzzle.grid) {
      for (var cell in row) {
        if (cell.isBlank) {
          List<List<Cell>> newGrid = puzzle.grid
              .map((r) => r.map((c) => c).toList())
              .toList();

          newGrid[cell.row][cell.col] = cell.copyWith(
            state: CellState.hint,
          );

          // 사용 가능한 글자에서 제거
          List<String> newAvailable = List.from(puzzle.availableLetters);
          newAvailable.remove(cell.correctLetter);

          return puzzle.copyWith(
            grid: newGrid,
            availableLetters: newAvailable,
          );
        }
      }
    }
    return puzzle;
  }

  /// 힌트 사용: 단어 뜻 보기
  String? getWordMeaning(Puzzle puzzle, int row, int col) {
    final cell = puzzle.grid[row][col];
    if (cell.wordIndices.isEmpty) return null;

    final wordIndex = cell.wordIndices.first;
    return puzzle.words[wordIndex].meaning;
  }

  /// 힌트 사용: 틀린 글자 표시
  Puzzle showWrongLetters(Puzzle puzzle) {
    List<List<Cell>> newGrid = puzzle.grid
        .map((r) => r.map((c) => c).toList())
        .toList();

    for (int row = 0; row < puzzle.gridSize; row++) {
      for (int col = 0; col < puzzle.gridSize; col++) {
        final cell = newGrid[row][col];
        if (cell.state == CellState.filled &&
            cell.userLetter != cell.correctLetter) {
          newGrid[row][col] = cell.copyWith(state: CellState.wrong);
        }
      }
    }

    return puzzle.copyWith(grid: newGrid);
  }

  /// 점수 계산
  int calculateLevelScore(Puzzle puzzle, {int hintsUsed = 0}) {
    int baseScore = puzzle.score;
    int hintPenalty = hintsUsed * 5;
    return (baseScore - hintPenalty).clamp(0, baseScore);
  }

  /// 코인 보상 계산
  int calculateCoins(int score) {
    return score ~/ 10;
  }
}
