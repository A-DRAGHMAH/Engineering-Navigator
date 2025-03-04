// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'user/user_home.dart';
// ignore: unused_import
import 'admin/admin_login.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const WelcomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Base Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1a237e),
                  const Color(0xFF0d47a1),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Animated particles overlay
          const Positioned.fill(
            child: ParticleOverlay(),
          ),

          // Professional Content Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Actions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Admin Access Button with red theme
                      Container(
                        margin: const EdgeInsets.only(top: 16, right: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.red[700]!,
                              Colors.red[900]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red[900]!.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pushNamed(context, '/admin'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.admin_panel_settings_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Admin Access',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Theme Toggle Button
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return RotationTransition(
                                turns: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              widget.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              key: ValueKey<bool>(widget.isDarkMode),
                              color: Colors.white,
                            ),
                          ),
                          onPressed: widget.onThemeToggle,
                          tooltip: widget.isDarkMode
                              ? 'Switch to Light Mode'
                              : 'Switch to Dark Mode',
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Logo and Title Section
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // Professional Logo Container
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF1565C0).withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.engineering,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Professional Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFE0E0E0), // Subtle gradient
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Column(
                              children: [
                                Text(
                                  'Engineering',
                                  style: TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  'Navigator',
                                  style: TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Professional Subtitle
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                              ),
                            ),
                            child: const Text(
                              'Your Professional Academic Companion',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Navigation Buttons Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        // Student Portal Button
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.2),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: Colors.white.withOpacity(0.2),
                                    highlightColor:
                                        Colors.white.withOpacity(0.2),
                                    onTap: () {
                                      // Add ripple animation
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();

                                      // Show loading indicator
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child:
                                                const CircularProgressIndicator(),
                                          ),
                                        ),
                                      );

                                      // Delayed navigation with animation
                                      Future.delayed(
                                          const Duration(milliseconds: 800),
                                          () {
                                        // ignore: use_build_context_synchronously
                                        Navigator.of(context)
                                            .pop(); // Remove loading indicator
                                        Navigator.pushReplacement(
                                          // ignore: use_build_context_synchronously
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                UserHomePage(
                                              onThemeToggle:
                                                  widget.onThemeToggle,
                                              isDarkMode: widget.isDarkMode,
                                            ),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              const begin = Offset(1.0, 0.0);
                                              const end = Offset.zero;
                                              const curve =
                                                  Curves.easeInOutCubic;
                                              var tween = Tween(
                                                      begin: begin, end: end)
                                                  .chain(
                                                      CurveTween(curve: curve));
                                              var offsetAnimation =
                                                  animation.drive(tween);
                                              return SlideTransition(
                                                position: offsetAnimation,
                                                child: child,
                                              );
                                            },
                                            transitionDuration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.navigation_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Let\'s Start Navigation',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for access buttons
class AccessButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(20, 0);
    path.lineTo(size.width - 40, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height - 20);
    path.quadraticBezierTo(
        size.width, size.height, size.width - 20, size.height);
    path.lineTo(40, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 20);
    path.lineTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Animated gradient background
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Color> colorSet1 = [
    const Color(0xFF1a237e), // Deep Blue
    const Color(0xFF0d47a1), // Rich Blue
    const Color(0xFF0277bd), // Modern Blue
  ];

  final List<Color> colorSet2 = [
    const Color(0xFF0d47a1), // Rich Blue
    const Color(0xFF1565C0), // Bright Blue
    const Color(0xFF1976D2), // Light Blue
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(colorSet1[0], colorSet2[0], _controller.value)!,
                Color.lerp(colorSet1[1], colorSet2[1], _controller.value)!,
                Color.lerp(colorSet1[2], colorSet2[2], _controller.value)!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class FloatingShapesBackground extends StatefulWidget {
  const FloatingShapesBackground({super.key});

  @override
  State<FloatingShapesBackground> createState() =>
      _FloatingShapesBackgroundState();
}

class _FloatingShapesBackgroundState extends State<FloatingShapesBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final List<FloatingShape> _shapes = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Only initialize controllers here
    const int numberOfShapes = 10;
    _controllers = List.generate(
      numberOfShapes,
      (index) => AnimationController(
        duration: Duration(seconds: Random().nextInt(15) + 15),
        vsync: this,
      )..repeat(reverse: true),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeShapes();
      _initialized = true;
    }
  }

  void _initializeShapes() {
    _shapes.clear();
    const int numberOfShapes = 10;

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    for (int i = 0; i < numberOfShapes; i++) {
      _shapes.add(FloatingShape(
        size: Random().nextDouble() * 200 + 100,
        initialPosition: Offset(
          Random().nextDouble() * width,
          Random().nextDouble() * height,
        ),
        color: Colors.white.withOpacity(Random().nextDouble() * 0.05),
      ));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(_shapes.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Positioned(
              left: _shapes[index].initialPosition.dx +
                  50 * sin(_animations[index].value * 2 * pi),
              top: _shapes[index].initialPosition.dy +
                  50 * cos(_animations[index].value * 2 * pi),
              child: Transform.rotate(
                angle: _animations[index].value * pi / 2,
                child: Container(
                  width: _shapes[index].size,
                  height: _shapes[index].size,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        _shapes[index].color,
                        _shapes[index].color.withOpacity(0.0),
                      ],
                      stops: const [0.1, 1.0],
                    ),
                    borderRadius:
                        BorderRadius.circular(_shapes[index].size / 2),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class FloatingShape {
  final double size;
  final Offset initialPosition;
  final Color color;

  FloatingShape({
    required this.size,
    required this.initialPosition,
    required this.color,
  });
}
