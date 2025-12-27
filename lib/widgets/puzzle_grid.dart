import 'package:flutter/material.dart';
import '../models/models.dart';

class PuzzleGrid extends StatelessWidget {
  final Puzzle puzzle;
  final Function(int row, int col) onCellTap;

  const PuzzleGrid({
    super.key,
    required this.puzzle,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: puzzle.gridSize,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: puzzle.gridSize * puzzle.gridSize,
          itemBuilder: (context, index) {
            final row = index ~/ puzzle.gridSize;
            final col = index % puzzle.gridSize;
            final cell = puzzle.grid[row][col];

            return _buildCell(cell, row, col);
          },
        ),
      ),
    );
  }

  Widget _buildCell(Cell cell, int row, int col) {
    if (cell.isEmpty) {
      return const SizedBox();
    }

    final isSelected = puzzle.selectedRow == row && puzzle.selectedCol == col;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (cell.state) {
      case CellState.hint:
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        borderColor = const Color(0xFF4CAF50);
        break;
      case CellState.blank:
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = Colors.transparent;
        borderColor = isSelected ? const Color(0xFFFF9800) : const Color(0xFF2196F3);
        break;
      case CellState.filled:
        backgroundColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFFF9800);
        borderColor = isSelected ? const Color(0xFFFF9800) : const Color(0xFFFFB74D);
        break;
      case CellState.correct:
        backgroundColor = const Color(0xFFC8E6C9);
        textColor = const Color(0xFF2E7D32);
        borderColor = const Color(0xFF4CAF50);
        break;
      case CellState.wrong:
        backgroundColor = const Color(0xFFFFCDD2);
        textColor = const Color(0xFFD32F2F);
        borderColor = const Color(0xFFE57373);
        break;
      default:
        backgroundColor = Colors.white;
        textColor = Colors.black;
        borderColor = Colors.grey;
    }

    return GestureDetector(
      onTap: cell.isSelectable ? () => onCellTap(row, col) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            cell.displayLetter,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
