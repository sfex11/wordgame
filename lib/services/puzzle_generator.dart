import 'dart:math';
import '../models/models.dart';
import '../data/word_data.dart';

/// 퍼즐 생성 서비스
class PuzzleGenerator {
  final Random _random = Random();

  /// 레벨별 설정
  static const Map<int, Map<String, int>> levelConfig = {
    1: {'words': 4, 'gridSize': 5, 'hintPercent': 50},
    11: {'words': 5, 'gridSize': 6, 'hintPercent': 40},
    21: {'words': 6, 'gridSize': 7, 'hintPercent': 30},
    31: {'words': 7, 'gridSize': 8, 'hintPercent': 25},
    41: {'words': 8, 'gridSize': 8, 'hintPercent': 20},
  };

  /// 레벨에 맞는 설정 가져오기
  Map<String, int> getConfigForLevel(int level) {
    int configLevel = 1;
    for (int l in levelConfig.keys) {
      if (level >= l) configLevel = l;
    }
    return levelConfig[configLevel]!;
  }

  /// 퍼즐 생성
  Puzzle generatePuzzle(int level) {
    final config = getConfigForLevel(level);
    return generatePuzzleWithConfig(
      level,
      config['words']!,
      config['gridSize']!,
      config['hintPercent']!,
    );
  }

  /// 설정으로 퍼즐 생성
  Puzzle generatePuzzleWithConfig(
    int level,
    int wordCount,
    int gridSize,
    int hintPercent,
  ) {
    // 단어 선택
    final selectedWords = _selectWords(wordCount);

    // 격자에 단어 배치 시도
    List<PlacedWord>? placedWords;
    List<List<Cell>>? grid;

    for (int attempt = 0; attempt < 20; attempt++) {
      final result = _placeWordsOnGrid(selectedWords, gridSize);
      if (result != null) {
        placedWords = result.$1;
        grid = result.$2;
        break;
      }
    }

    // 실패 시 기본 배치 (간단한 가로/세로)
    if (placedWords == null || grid == null) {
      final fallback = _createFallbackPuzzle(selectedWords, gridSize);
      placedWords = fallback.$1;
      grid = fallback.$2;
    }

    // 힌트 글자 설정
    placedWords = _setHints(placedWords, hintPercent);

    // 격자 상태 업데이트
    grid = _updateGridWithHints(grid, placedWords);

    // 사용 가능한 글자 추출
    final availableLetters = _extractAvailableLetters(grid, placedWords);

    return Puzzle(
      level: level,
      gridSize: gridSize,
      grid: grid,
      words: placedWords,
      availableLetters: availableLetters,
    );
  }

  /// 단어 선택
  List<Word> _selectWords(int count) {
    final shuffled = List<Map<String, String>>.from(wordDatabase)..shuffle(_random);
    return shuffled
        .take(count * 3) // 여유롭게 선택
        .map((w) => Word(text: w['text']!, meaning: w['meaning']!))
        .where((w) => w.length >= 2 && w.length <= 5)
        .take(count)
        .toList();
  }

  /// 격자에 단어 배치
  (List<PlacedWord>, List<List<Cell>>)? _placeWordsOnGrid(
      List<Word> words, int gridSize) {
    // 빈 격자 생성
    List<List<Cell>> grid = List.generate(
      gridSize,
      (row) => List.generate(
        gridSize,
        (col) => Cell(row: row, col: col, state: CellState.empty),
      ),
    );

    List<PlacedWord> placedWords = [];
    List<Word> sortedWords = List.from(words)
      ..sort((a, b) => b.length.compareTo(a.length));

    for (int i = 0; i < sortedWords.length; i++) {
      final word = sortedWords[i];
      final placement = _findPlacement(grid, word, placedWords, gridSize);

      if (placement == null) {
        return null; // 배치 실패
      }

      final (row, col, direction) = placement;
      final placedWord = PlacedWord(
        word: word,
        startRow: row,
        startCol: col,
        direction: direction,
      );

      // 격자 업데이트
      grid = _placeWordOnGrid(grid, placedWord, placedWords.length);
      placedWords.add(placedWord);
    }

    // 모든 단어가 연결되어 있는지 확인
    if (!_areAllWordsConnected(placedWords)) {
      return null;
    }

    return (placedWords, grid);
  }

  /// 단어 배치 위치 찾기
  (int, int, Direction)? _findPlacement(
      List<List<Cell>> grid,
      Word word,
      List<PlacedWord> placedWords,
      int gridSize) {
    List<(int, int, Direction)> candidates = [];

    // 첫 번째 단어는 중앙에 배치
    if (placedWords.isEmpty) {
      int startRow = gridSize ~/ 2;
      int startCol = (gridSize - word.length) ~/ 2;
      if (startCol >= 0 && startCol + word.length <= gridSize) {
        return (startRow, startCol, Direction.horizontal);
      }
      return null;
    }

    // 기존 단어들과 교차하는 위치 찾기
    for (final placed in placedWords) {
      for (int i = 0; i < placed.length; i++) {
        final (placedRow, placedCol) = placed.getPosition(i);
        final placedLetter = placed.text[i];

        // 새 단어에서 같은 글자 찾기
        for (int j = 0; j < word.length; j++) {
          if (word.text[j] == placedLetter) {
            // 교차 방향 결정
            final newDirection = placed.direction == Direction.horizontal
                ? Direction.vertical
                : Direction.horizontal;

            int newRow, newCol;
            if (newDirection == Direction.horizontal) {
              newRow = placedRow;
              newCol = placedCol - j;
            } else {
              newRow = placedRow - j;
              newCol = placedCol;
            }

            // 유효성 검사
            if (_canPlaceWord(grid, word, newRow, newCol, newDirection, gridSize)) {
              candidates.add((newRow, newCol, newDirection));
            }
          }
        }
      }
    }

    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }

  /// 단어 배치 가능 여부 확인
  bool _canPlaceWord(
      List<List<Cell>> grid,
      Word word,
      int startRow,
      int startCol,
      Direction direction,
      int gridSize) {
    // 범위 체크
    if (startRow < 0 || startCol < 0) return false;
    if (direction == Direction.horizontal) {
      if (startCol + word.length > gridSize) return false;
    } else {
      if (startRow + word.length > gridSize) return false;
    }

    // 각 셀 체크
    for (int i = 0; i < word.length; i++) {
      int row = direction == Direction.vertical ? startRow + i : startRow;
      int col = direction == Direction.horizontal ? startCol + i : startCol;

      final cell = grid[row][col];
      if (!cell.isEmpty) {
        // 이미 글자가 있으면 같은 글자인지 확인
        if (cell.correctLetter != word.text[i]) {
          return false;
        }
      }

      // 인접 셀 체크 (평행하게 붙어있으면 안됨)
      if (!_checkAdjacentCells(grid, row, col, direction, gridSize, word.text[i])) {
        return false;
      }
    }

    // 앞뒤 공간 체크
    if (direction == Direction.horizontal) {
      if (startCol > 0 && !grid[startRow][startCol - 1].isEmpty) return false;
      if (startCol + word.length < gridSize &&
          !grid[startRow][startCol + word.length].isEmpty) return false;
    } else {
      if (startRow > 0 && !grid[startRow - 1][startCol].isEmpty) return false;
      if (startRow + word.length < gridSize &&
          !grid[startRow + word.length][startCol].isEmpty) return false;
    }

    return true;
  }

  /// 인접 셀 체크
  bool _checkAdjacentCells(
      List<List<Cell>> grid,
      int row,
      int col,
      Direction direction,
      int gridSize,
      String letter) {
    // 교차하는 방향의 인접 셀만 체크
    if (direction == Direction.horizontal) {
      // 위아래 셀
      bool hasAbove = row > 0 && !grid[row - 1][col].isEmpty;
      bool hasBelow = row < gridSize - 1 && !grid[row + 1][col].isEmpty;

      // 현재 셀이 비어있는데 위아래에 글자가 있으면 불가
      if (grid[row][col].isEmpty && (hasAbove || hasBelow)) {
        // 단, 교차점인 경우는 허용
        if (!(hasAbove && grid[row - 1][col].correctLetter == letter) &&
            !(hasBelow && grid[row + 1][col].correctLetter == letter)) {
          return false;
        }
      }
    } else {
      // 좌우 셀
      bool hasLeft = col > 0 && !grid[row][col - 1].isEmpty;
      bool hasRight = col < gridSize - 1 && !grid[row][col + 1].isEmpty;

      if (grid[row][col].isEmpty && (hasLeft || hasRight)) {
        if (!(hasLeft && grid[row][col - 1].correctLetter == letter) &&
            !(hasRight && grid[row][col + 1].correctLetter == letter)) {
          return false;
        }
      }
    }

    return true;
  }

  /// 격자에 단어 배치
  List<List<Cell>> _placeWordOnGrid(
      List<List<Cell>> grid, PlacedWord placedWord, int wordIndex) {
    List<List<Cell>> newGrid = grid.map((row) => row.map((c) => c).toList()).toList();

    for (int i = 0; i < placedWord.length; i++) {
      final (row, col) = placedWord.getPosition(i);
      final letter = placedWord.text[i];
      final currentCell = newGrid[row][col];

      List<int> wordIndices = List.from(currentCell.wordIndices)..add(wordIndex);

      newGrid[row][col] = currentCell.copyWith(
        correctLetter: letter,
        state: CellState.blank,
        wordIndices: wordIndices,
      );
    }

    return newGrid;
  }

  /// 모든 단어가 연결되어 있는지 확인
  bool _areAllWordsConnected(List<PlacedWord> words) {
    if (words.length <= 1) return true;

    Set<int> connected = {0};
    bool changed = true;

    while (changed) {
      changed = false;
      for (int i = 0; i < words.length; i++) {
        if (connected.contains(i)) continue;

        for (int j in connected) {
          if (_wordsIntersect(words[i], words[j])) {
            connected.add(i);
            changed = true;
            break;
          }
        }
      }
    }

    return connected.length == words.length;
  }

  /// 두 단어가 교차하는지 확인
  bool _wordsIntersect(PlacedWord w1, PlacedWord w2) {
    for (int i = 0; i < w1.length; i++) {
      final (r1, c1) = w1.getPosition(i);
      for (int j = 0; j < w2.length; j++) {
        final (r2, c2) = w2.getPosition(j);
        if (r1 == r2 && c1 == c2) return true;
      }
    }
    return false;
  }

  /// 힌트 설정
  List<PlacedWord> _setHints(List<PlacedWord> words, int hintPercent) {
    return words.map((word) {
      int hintCount = max(1, (word.length * hintPercent / 100).round());
      List<int> allIndices = List.generate(word.length, (i) => i);
      allIndices.shuffle(_random);
      List<int> hintIndices = allIndices.take(hintCount).toList()..sort();
      return word.copyWith(hintIndices: hintIndices);
    }).toList();
  }

  /// 힌트에 따라 격자 상태 업데이트
  List<List<Cell>> _updateGridWithHints(
      List<List<Cell>> grid, List<PlacedWord> words) {
    List<List<Cell>> newGrid = grid.map((row) => row.map((c) => c).toList()).toList();

    for (int wordIndex = 0; wordIndex < words.length; wordIndex++) {
      final word = words[wordIndex];
      for (int hintIndex in word.hintIndices) {
        final (row, col) = word.getPosition(hintIndex);
        newGrid[row][col] = newGrid[row][col].copyWith(state: CellState.hint);
      }
    }

    return newGrid;
  }

  /// 사용 가능한 글자 추출
  List<String> _extractAvailableLetters(
      List<List<Cell>> grid, List<PlacedWord> words) {
    List<String> letters = [];

    for (var row in grid) {
      for (var cell in row) {
        if (cell.state == CellState.blank && cell.correctLetter != null) {
          letters.add(cell.correctLetter!);
        }
      }
    }

    letters.shuffle(_random);
    return letters;
  }

  /// 폴백 퍼즐 생성 (간단한 배치)
  (List<PlacedWord>, List<List<Cell>>) _createFallbackPuzzle(
      List<Word> words, int gridSize) {
    List<List<Cell>> grid = List.generate(
      gridSize,
      (row) => List.generate(
        gridSize,
        (col) => Cell(row: row, col: col, state: CellState.empty),
      ),
    );

    List<PlacedWord> placedWords = [];
    int currentRow = 1;

    for (int i = 0; i < words.length && currentRow < gridSize - 1; i++) {
      final word = words[i];
      if (word.length <= gridSize - 2) {
        final placedWord = PlacedWord(
          word: word,
          startRow: currentRow,
          startCol: 1,
          direction: Direction.horizontal,
        );
        grid = _placeWordOnGrid(grid, placedWord, placedWords.length);
        placedWords.add(placedWord);
        currentRow += 2;
      }
    }

    return (placedWords, grid);
  }
}
