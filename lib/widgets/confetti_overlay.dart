import 'dart:math';
import 'package:flutter/material.dart';

/// 축하 효과를 위한 컨페티 오버레이 위젯
class ConfettiOverlay extends StatefulWidget {
  final bool isPlaying;
  final Widget child;

  const ConfettiOverlay({
    super.key,
    required this.isPlaying,
    required this.child,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _particles = List.generate(50, (_) => _createParticle());

    _controller.addListener(() {
      setState(() {});
    });

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _particles = List.generate(50, (_) => _createParticle());
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ConfettiParticle _createParticle() {
    return ConfettiParticle(
      x: _random.nextDouble(),
      y: -_random.nextDouble() * 0.3,
      rotation: _random.nextDouble() * 2 * pi,
      rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      velocity: 0.3 + _random.nextDouble() * 0.7,
      size: 8 + _random.nextDouble() * 8,
      color: _confettiColors[_random.nextInt(_confettiColors.length)],
      shape: ConfettiShape.values[_random.nextInt(ConfettiShape.values.length)],
    );
  }

  static const List<Color> _confettiColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFFAA96DA),
    Color(0xFFFFAA5C),
    Color(0xFF7DCE82),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating || _controller.value > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ConfettiPainter(
                  particles: _particles,
                  progress: _controller.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum ConfettiShape { square, circle, rectangle }

class ConfettiParticle {
  final double x;
  final double y;
  final double rotation;
  final double rotationSpeed;
  final double velocity;
  final double size;
  final Color color;
  final ConfettiShape shape;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.rotation,
    required this.rotationSpeed,
    required this.velocity,
    required this.size,
    required this.color,
    required this.shape,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final x = particle.x * size.width;
      final y = particle.y * size.height + progress * size.height * particle.velocity * 1.5;
      final rotation = particle.rotation + progress * particle.rotationSpeed;
      final opacity = (1 - progress).clamp(0.0, 1.0);

      if (y > size.height) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      switch (particle.shape) {
        case ConfettiShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case ConfettiShape.rectangle:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size / 2,
            ),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 별이 터지는 효과
class StarBurstEffect extends StatefulWidget {
  final bool isPlaying;
  final Widget child;

  const StarBurstEffect({
    super.key,
    required this.isPlaying,
    required this.child,
  });

  @override
  State<StarBurstEffect> createState() => _StarBurstEffectState();
}

class _StarBurstEffectState extends State<StarBurstEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    if (widget.isPlaying) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(StarBurstEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: StarBurstPainter(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class StarBurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final start = Offset(
        center.dx + 30 * cos(angle),
        center.dy + 30 * sin(angle),
      );
      final end = Offset(
        center.dx + 80 * cos(angle),
        center.dy + 80 * sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
