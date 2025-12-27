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

            return _AnimatedCell(
              cell: cell,
              row: row,
              col: col,
              isSelected: puzzle.selectedRow == row && puzzle.selectedCol == col,
              onTap: onCellTap,
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedCell extends StatefulWidget {
  final Cell cell;
  final int row;
  final int col;
  final bool isSelected;
  final Function(int row, int col) onTap;

  const _AnimatedCell({
    required this.cell,
    required this.row,
    required this.col,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedCell> createState() => _AnimatedCellState();
}

class _AnimatedCellState extends State<_AnimatedCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  CellState? _previousState;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _previousState = widget.cell.state;
  }

  @override
  void didUpdateWidget(_AnimatedCell oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 상태가 correct로 변경되면 바운스 애니메이션
    if (widget.cell.state == CellState.correct &&
        _previousState != CellState.correct) {
      _controller.forward().then((_) => _controller.reverse());
    }

    // 상태가 filled로 변경되면 작은 펄스
    if (widget.cell.state == CellState.filled &&
        _previousState == CellState.blank) {
      _controller.forward().then((_) => _controller.reverse());
    }

    _previousState = widget.cell.state;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cell.isEmpty) {
      return const SizedBox();
    }

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (widget.cell.state) {
      case CellState.hint:
        backgroundColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        borderColor = const Color(0xFF4CAF50);
        break;
      case CellState.blank:
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = Colors.transparent;
        borderColor =
            widget.isSelected ? const Color(0xFFFF9800) : const Color(0xFF2196F3);
        break;
      case CellState.filled:
        backgroundColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFFF9800);
        borderColor =
            widget.isSelected ? const Color(0xFFFF9800) : const Color(0xFFFFB74D);
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
      onTap: widget.cell.isSelectable ? () => widget.onTap(widget.row, widget.col) : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = widget.cell.state == CellState.correct
              ? _bounceAnimation.value
              : _scaleAnimation.value;

          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: widget.isSelected ? 3 : 2,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: borderColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : widget.cell.state == CellState.correct
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              child: Text(widget.cell.displayLetter),
            ),
          ),
        ),
      ),
    );
  }
}
