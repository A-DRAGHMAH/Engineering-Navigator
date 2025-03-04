// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<ParticleModel> particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Create particles
    for (int i = 0; i < 50; i++) {
      particles.add(ParticleModel());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1F3C).withOpacity(0.95),
                const Color(0xFF2D3250).withOpacity(0.95),
                const Color(0xFF3D0000).withOpacity(0.95),
              ],
            ),
          ),
        ),
        
        // Animated particles
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: particles,
                animation: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Content with blur effect
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: widget.child,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ParticleModel {
  late double x;
  late double y;
  late double speed;
  late double size;
  late Color color;

  ParticleModel() {
    reset();
  }

  void reset() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    speed = 0.02 + random.nextDouble() * 0.04;
    size = 2 + random.nextDouble() * 3;
    color = Colors.white.withOpacity(0.1 + random.nextDouble() * 0.1);
  }
}

class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;
  final double animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      var position = Offset(
        particle.x * size.width,
        (particle.y - animation * particle.speed) % 1.0 * size.height,
      );
      paint.color = particle.color;
      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
} 