import 'package:flutter/material.dart';

class LetterBank extends StatelessWidget {
  final List<String> letters;
  final Function(String letter) onLetterTap;

  const LetterBank({
    super.key,
    required this.letters,
    required this.onLetterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: letters
            .asMap()
            .entries
            .map((entry) => _AnimatedLetterButton(
                  letter: entry.value,
                  index: entry.key,
                  onTap: onLetterTap,
                ))
            .toList(),
      ),
    );
  }
}

class _AnimatedLetterButton extends StatefulWidget {
  final String letter;
  final int index;
  final Function(String letter) onTap;

  const _AnimatedLetterButton({
    required this.letter,
    required this.index,
    required this.onTap,
  });

  @override
  State<_AnimatedLetterButton> createState() => _AnimatedLetterButtonState();
}

class _AnimatedLetterButtonState extends State<_AnimatedLetterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap(widget.letter);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFFE8F5E9) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isPressed
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFF4CAF50),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(_isPressed ? 0.4 : 0.2),
                blurRadius: _isPressed ? 8 : 4,
                offset: Offset(0, _isPressed ? 1 : 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.letter,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _isPressed
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF4CAF50),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
