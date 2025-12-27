import 'package:equatable/equatable.dart';

/// 격자 셀 상태
enum CellState {
  empty,      // 빈 공간 (사용 안함)
  hint,       // 힌트로 주어진 글자
  blank,      // 사용자가 채워야 할 빈칸
  filled,     // 사용자가 채운 글자
  correct,    // 정답으로 확정된 글자
  wrong,      // 틀린 글자 (검증 후)
}

/// 격자 셀 모델
class Cell extends Equatable {
  final int row;
  final int col;
  final String? correctLetter;  // 정답 글자
  final String? userLetter;     // 사용자가 입력한 글자
  final CellState state;
  final List<int> wordIndices;  // 이 셀이 속한 단어 인덱스들

  const Cell({
    required this.row,
    required this.col,
    this.correctLetter,
    this.userLetter,
    this.state = CellState.empty,
    this.wordIndices = const [],
  });

  bool get isEmpty => state == CellState.empty;
  bool get isHint => state == CellState.hint;
  bool get isBlank => state == CellState.blank;
  bool get isFilled => state == CellState.filled;
  bool get isCorrect => state == CellState.correct;
  bool get isWrong => state == CellState.wrong;
  bool get isSelectable => state == CellState.blank || state == CellState.filled;

  String get displayLetter {
    if (state == CellState.hint || state == CellState.correct) {
      return correctLetter ?? '';
    }
    return userLetter ?? '';
  }

  Cell copyWith({
    int? row,
    int? col,
    String? correctLetter,
    String? userLetter,
    CellState? state,
    List<int>? wordIndices,
  }) {
    return Cell(
      row: row ?? this.row,
      col: col ?? this.col,
      correctLetter: correctLetter ?? this.correctLetter,
      userLetter: userLetter ?? this.userLetter,
      state: state ?? this.state,
      wordIndices: wordIndices ?? this.wordIndices,
    );
  }

  @override
  List<Object?> get props => [row, col, correctLetter, userLetter, state, wordIndices];
}
