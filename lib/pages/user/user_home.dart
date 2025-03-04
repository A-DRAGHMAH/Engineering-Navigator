// ignore_for_file: camel_case_types, unused_element, deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'calendar_page.dart';
import 'courses_page.dart';
import 'faculty_page.dart';
import 'links_page.dart';
import 'notifications_page.dart';
import 'chatbot_page.dart';
import 'exam_schedules_page.dart';
import 'study_materials_page.dart';
import 'hall_videos_page.dart';
import 'dart:math' show pi, cos, sin, Random;
import 'package:aaup/pages/user/user_educational_programs.dart';

class UserHomePage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const UserHomePage({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimationController;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  onPressed: () => _showExitDialog(context),
                  tooltip: 'Return to Welcome Screen',
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: IconButton(
                    icon: Icon(
                      widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    onPressed: widget.onThemeToggle,
                    tooltip: 'Toggle Theme',
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Modern background gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1a237e),
                            Color(0xFF0d47a1),
                            Color(0xFF0277bd),
                          ],
                        ),
                      ),
                    ),

                    // Animated particles overlay
                    const Positioned.fill(
                      child: ParticleOverlay(),
                    ),

                    // Main content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Modern header with glowing effect
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Animated logo
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.engineering,
                                      color: Colors.white,
                                      size: 36,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Engineering Navigator',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Student Portal',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Your existing quick access buttons
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildQuickAccessButton(
                                    context,
                                    'Chat',
                                    Icons.chat_bubble_outline,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UserChatbotPage(),
                                      ),
                                    ),
                                  ),
                                  _buildQuickAccessButton(
                                    context,
                                    'Materials',
                                    Icons.book_outlined,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UserStudyMaterialsPage(),
                                      ),
                                    ),
                                  ),
                                  _buildQuickAccessButton(
                                    context,
                                    'Exams',
                                    Icons.assignment_outlined,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const UserExamSchedulesPage(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('AI Assistant', Icons.smart_toy),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF673AB7).withOpacity(0.9),
                            const Color(0xFF512DA8).withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserChatbotPage(),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Engineering Assistant',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Get instant help with your engineering queries',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildSectionTitle('Academic Resources', Icons.school),
                    _buildFeatureSection(
                      'Courses',
                      Icons.school_outlined,
                      const Color(0xFF1976D2),
                      'Access your course materials and schedules',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserCoursesPage()),
                      ),
                    ),
                    _buildFeatureSection(
                      'Study Materials',
                      Icons.book_outlined,
                      const Color(0xFF0277BD),
                      'Browse through study resources and materials',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const UserStudyMaterialsPage()),
                      ),
                    ),
                    _buildFeatureSection(
                      'Exams',
                      Icons.assignment_outlined,
                      const Color(0xFF00838F),
                      'View exam schedules and important dates',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const UserExamSchedulesPage()),
                      ),
                    ),
                    _buildFeatureSection(
                      'Faculty',
                      Icons.people_outline,
                      const Color(0xFF00695C),
                      'Connect with faculty members and advisors',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserFacultyPage()),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Information', Icons.info_outline),
                    _buildFeatureSection(
                      'Events',
                      Icons.event_outlined,
                      const Color(0xFF455A64),
                      'Stay updated with university events and activities',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserCalendarPage()),
                      ),
                    ),
                    _buildFeatureSection(
                      'Notifications',
                      Icons.notifications_none,
                      const Color(0xFF37474F),
                      'Check important announcements and updates',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const UserNotificationsPage()),
                      ),
                    ),
                    _buildFeatureSection(
                      'Important Links',
                      Icons.link_rounded,
                      const Color(0xFF263238),
                      'Access essential university resources and links',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserLinksPage()),
                      ),
                    ),
                    _buildFeatureSection(
                      'Hall Videos',
                      Icons.video_library,
                      const Color(0xFF00796B),
                      'View hall location videos',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserHallVideosPage()),
                      ),
                    ),
                    _buildFeatureSection(
                      'Educational Programs',
                      Icons.school,
                      const Color(0xFF1976D2),
                      'Access educational programs and resources',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const UserEducationalProgramsPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.white70],
            ).createShader(bounds),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit to Welcome Screen'),
        content: const Text(
            'Are you sure you want to return to the welcome screen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSection(String title, IconData icon, Color color,
      String description, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
    Color startColor,
    Color endColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  startColor.withOpacity(0.2),
                  endColor.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Add ripple effect
                  HapticFeedback.mediumImpact();
                  // Add scale animation
                  ScaffoldMessenger.of(context).clearSnackBars();
                  onTap();
                },
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: startColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GeometricPatternPainter extends CustomPainter {
  final Color color;

  GeometricPatternPainter(
      {required this.color, required int spacing, required int hexSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double spacing = 50;
    const double hexSize = 30;

    for (double x = 0; x < size.width + hexSize; x += spacing) {
      for (double y = 0; y < size.height + hexSize; y += spacing) {
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * pi / 3);
          final double hx = x + cos(angle) * hexSize;
          final double hy = y + sin(angle) * hexSize;
          if (i == 0) {
            path.moveTo(hx, hy);
          } else {
            path.lineTo(hx, hy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ParticleOverlay extends StatefulWidget {
  const ParticleOverlay({super.key});

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> particles = List.generate(20, (index) => Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
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
          painter: ParticlePainter(
            particles: particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double speed;
  double theta;

  Particle()
      : x = Random().nextDouble(),
        y = Random().nextDouble(),
        speed = Random().nextDouble() * 0.2 + 0.1,
        theta = Random().nextDouble() * 2 * pi;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      final offset = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );
      canvas.drawCircle(offset, 2, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

// Custom clipper for unconventional shape
class FeatureCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.lineTo(0, size.height);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.lineTo(size.width * 0.2, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
