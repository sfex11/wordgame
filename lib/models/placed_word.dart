import 'package:equatable/equatable.dart';
import 'word.dart';

/// 단어 배치 방향
enum Direction {
  horizontal,
  vertical,
}

/// 격자에 배치된 단어 모델
class PlacedWord extends Equatable {
  final Word word;
  final int startRow;
  final int startCol;
  final Direction direction;
  final List<int> hintIndices;  // 힌트로 공개된 글자 인덱스
  final bool isCompleted;

  const PlacedWord({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
    this.hintIndices = const [],
    this.isCompleted = false,
  });

  int get length => word.length;
  String get text => word.text;
  String get meaning => word.meaning;

  /// 단어의 끝 좌표
  int get endRow => direction == Direction.vertical
      ? startRow + length - 1
      : startRow;
  int get endCol => direction == Direction.horizontal
      ? startCol + length - 1
      : startCol;

  /// 특정 인덱스의 글자 좌표
  (int row, int col) getPosition(int index) {
    if (direction == Direction.horizontal) {
      return (startRow, startCol + index);
    } else {
      return (startRow + index, startCol);
    }
  }

  /// 특정 좌표가 이 단어에 속하는지 확인
  bool containsPosition(int row, int col) {
    if (direction == Direction.horizontal) {
      return row == startRow && col >= startCol && col <= endCol;
    } else {
      return col == startCol && row >= startRow && row <= endRow;
    }
  }

  /// 특정 좌표의 글자 인덱스 반환
  int? getIndexAt(int row, int col) {
    if (!containsPosition(row, col)) return null;
    if (direction == Direction.horizontal) {
      return col - startCol;
    } else {
      return row - startRow;
    }
  }

  PlacedWord copyWith({
    Word? word,
    int? startRow,
    int? startCol,
    Direction? direction,
    List<int>? hintIndices,
    bool? isCompleted,
  }) {
    return PlacedWord(
      word: word ?? this.word,
      startRow: startRow ?? this.startRow,
      startCol: startCol ?? this.startCol,
      direction: direction ?? this.direction,
      hintIndices: hintIndices ?? this.hintIndices,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [word, startRow, startCol, direction, hintIndices, isCompleted];
}
