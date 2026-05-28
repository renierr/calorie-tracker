import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiWidget extends StatefulWidget {
  final VoidCallback onFinished;

  const ConfettiWidget({super.key, required this.onFinished});

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished();
      }
    });

    // Create 60 colorful confetti particles with varied angles, shapes, and speeds
    final List<Color> colors = [
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];

    for (int i = 0; i < 70; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _random.nextDouble(), // 0.0 to 1.0 (percent of screen width)
          y: -0.1 - _random.nextDouble() * 0.4, // start above the screen
          size: 6.0 + _random.nextDouble() * 10.0,
          color: colors[_random.nextInt(colors.length)],
          speedY: 0.15 + _random.nextDouble() * 0.35,
          speedX: -0.15 + _random.nextDouble() * 0.3,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: -2.0 + _random.nextDouble() * 4.0,
          isCircle: _random.nextBool(),
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  double y;
  final double size;
  final Color color;
  final double speedY;
  final double speedX;
  double rotation;
  final double rotationSpeed;
  final bool isCircle;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Calculate current coordinates based on animation progress
      final double currentX =
          (particle.x * size.width + particle.speedX * progress * size.width) %
          size.width;
      final double currentY =
          (particle.y + particle.speedY * progress) * size.height;
      final double currentRotation =
          particle.rotation + particle.rotationSpeed * progress;

      // Draw only if on screen
      if (currentY >= 0 && currentY <= size.height) {
        final paint = Paint()
          ..color = particle.color
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(currentX, currentY);
        canvas.rotate(currentRotation);

        if (particle.isCircle) {
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
        } else {
          final rect = Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          );
          canvas.drawRect(rect, paint);
        }
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
