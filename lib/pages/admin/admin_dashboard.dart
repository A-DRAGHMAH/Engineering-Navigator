// ignore_for_file: deprecated_member_use

import 'dart:ui';

// ignore: unused_import
import 'package:aaup/pages/admin/admin_login.dart';
import 'package:aaup/pages/admin/hall_videos_page.dart';
import 'package:aaup/pages/user/user_home.dart';

import '../../services/admin_service.dart';
import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'exam_schedules_page.dart';
import 'calendar_page.dart';
import 'courses_page.dart';
import 'links_page.dart';
import 'faculty_page.dart';
import 'study_materials_page.dart';
import 'settings_page.dart';
import '../../services/dashboard_service.dart';
import 'admin_educational_programs.dart';

const kPrimaryColor = Color(0xFFB71C1C); // Dark Red
const kSecondaryColor = Color(0xFFD32F2F); // Red
const kAccentColor = Color(0xFFFF5252); // Light Red
const kDarkBgStart = Color(0xFF1A1F3C); // Dark Navy
const kDarkBgEnd = Color(0xFF2D3250); // Dark Purple-Blue

// Professional gradients
final lightGradients = {
  'primary': [const Color(0xFFD32F2F), const Color(0xFFFF5252)],
  'success': [const Color(0xFF26A69A), const Color(0xFF80CBC4)],
  'warning': [const Color(0xFFFFB300), const Color(0xFFFFD54F)],
  'info': [const Color(0xFF7E57C2), const Color(0xFFB39DDB)],
};

final darkGradients = {
  'primary': [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
  'card': [const Color(0xFF252B48), const Color(0xFF2D3250)],
  'accent': [
    const Color(0xFFD32F2F).withOpacity(0.2),
    const Color(0xFFD32F2F).withOpacity(0.1)
  ],
};

bool _isDarkMode = true;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DashboardService _dashboardService = DashboardService();

  // Replace the menuItems list with these grouped items
  final Map<String, List<_MenuItem>> menuGroups = {
    'Academic Management': [
      _MenuItem(
        'Faculty Members',
        Icons.people_outline,
        const Color(0xFF1A237E),
        const AdminFacultyPage(),
        'Manage faculty profiles and departments',
      ),
      _MenuItem(
        'Course Management',
        Icons.school_outlined,
        const Color(0xFF283593),
        const AdminCoursesPage(),
        'Manage courses and curricula',
      ),
      _MenuItem(
        'Exam Schedules',
        Icons.assignment_outlined,
        const Color(0xFF303F9F),
        const AdminExamSchedulesPage(),
        'Manage examination timetables',
      ),
    ],
    'Resource Center': [
      _MenuItem(
        'Hall Videos',
        Icons.video_library,
        const Color(0xFF00796B),
        const AdminHallVideosPage(),
        'Manage hall location videos',
      ),
      _MenuItem(
        'Study Materials',
        Icons.book_outlined,
        const Color(0xFF0277BD),
        const AdminStudyMaterialsPage(),
        'Upload and manage learning resources',
      ),
      _MenuItem(
        'Important Links',
        Icons.link,
        const Color(0xFF039BE5),
        const AdminLinksPage(),
        'Manage external resources',
      ),
    ],
    'Event Planning': [
      _MenuItem(
        'Calendar Events',
        Icons.event_outlined,
        const Color(0xFF00796B),
        const AdminCalendarPage(),
        'Manage academic calendar',
      ),
    ],
    'System Settings': [
      _MenuItem(
        'System Config',
        Icons.settings_outlined,
        const Color(0xFF43A047),
        const AdminSettingsPage(),
        'Configure system settings',
      ),
    ],
    'Program Management': [
      _MenuItem(
        'Educational Programs',
        Icons.school,
        const Color(0xFF1A237E),
        const AdminEducationalProgramsPage(),
        'Manage educational programs for students',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    AdminService.createCoursesIndexes();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _dashboardService.getAdminDashboardTheme();
    setState(() {
      _isDarkMode = isDark;
      _updateTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isDarkMode
                ? [
                    const Color(0xFF1A1A2F), // Dark blue-gray
                    const Color(0xFF2B2B3F), // Slightly lighter
                    const Color(0xFF3D0000), // Dark red accent
                  ]
                : [
                    Theme.of(context)
                        .scaffoldBackgroundColor, // Light background
                    Colors.white, // White
                    Colors.grey[50]!, // Very light gray
                  ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Add particle overlay
            const Positioned.fill(
              child: ParticleOverlay(),
            ),

            // Keep existing SafeArea and content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Update header container styling
                    _buildHeader(),
                    // Update section titles styling
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStats(),
                          const SizedBox(height: 24),
                          _buildGlassSection('Quick Actions', Colors.red),
                          const SizedBox(height: 16),
                          _buildQuickActions(context),
                          const SizedBox(height: 24),
                          _buildGlassSection('Management', Colors.red),
                          const SizedBox(height: 16),
                          _buildManagementGrid(context),
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
    );
  }

  // Glass morphism section title
  Widget _buildGlassSection(String title, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: accentColor.withOpacity(0.1),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildQuickActionCard(
            context,
            'Send Notification',
            Icons.notifications_active_outlined,
            const Color(0xFF8B0000), // Dark red
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminNotificationsPage(
                  adminId: '',
                ),
              ),
            ),
          ),
          _buildQuickActionCard(
            context,
            'Add Faculty',
            Icons.person_add_outlined,
            const Color(0xFF990000), // Slightly lighter red
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminFacultyPage(),
              ),
            ),
          ),
          _buildQuickActionCard(
            context,
            'Add Event',
            Icons.event_outlined,
            const Color(0xFFA50000), // Medium red
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminCalendarPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Update quick action cards with glass effect
  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.3),
                  color.withOpacity(0.1),
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
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: menuGroups.entries.map((group) {
        return Card(
          key: ValueKey(group.key),
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.transparent,
          elevation: 4,
          child: ExpansionTile(
            title: Text(
              group.key,
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: group.value.length,
                itemBuilder: (context, index) =>
                    _buildMenuCard(context, group.value[index]),
              ),
            ],
          ),
        );
      }).toList(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final items = menuGroups.entries.toList();
          final item = items.removeAt(oldIndex);
          items.insert(newIndex, item);
          menuGroups.clear();
          menuGroups.addEntries(items);
        });
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, _MenuItem item) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDarkMode
                    ? darkGradients['card']!
                    : lightGradients['primary']!
                        .map((c) => c.withOpacity(0.1))
                        .toList(),
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _isDarkMode
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _navigateWithAnimation(context, item.page),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                item.icon,
                color: _isDarkMode ? Colors.white : Colors.black,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: TextStyle(
                color: _isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateWithAnimation(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  Widget _buildStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardService.getDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data ??
            {
              'adminLogins': 0,
              'totalUsers': 0,
              'totalSubjects': 0,
              'totalDoctors': 0,
            };

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              _buildStatCard(
                "Admin Logins",
                "${stats['adminLogins']}",
                Icons.admin_panel_settings,
                const Color(0xFF8B0000),
              ),
              _buildStatCard(
                "Students",
                "${stats['totalUsers']}",
                Icons.people,
                const Color(0xFF990000),
              ),
              _buildStatCard(
                "Subjects",
                "${stats['totalSubjects']}",
                Icons.book,
                const Color(0xFFA50000),
              ),
              _buildStatCard(
                "Doctors",
                "${stats['totalDoctors']}",
                Icons.school,
                const Color(0xFFB20000),
              ),
            ].map((widget) => Expanded(child: widget)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _updateTheme() {
    final lightColors = {
      'background': [
        const Color(0xFFF8F9FA), // Very light gray
        const Color(0xFFFFFFFF), // White
        const Color(0xFFF1F3F5), // Light gray
      ],
      'card': const Color(0xFFFFFFFF),
      'text': const Color(0xFF2C3E50), // Dark blue-gray
      'accent': const Color(0xFF1A237E).withOpacity(0.8),
      'border': const Color(0xFFE9ECEF), // Light gray border
    };

    final darkColors = {
      'background': [
        const Color(0xFF1A1A2F), // Dark blue-gray
        const Color(0xFF2B2B3F), // Slightly lighter
        const Color(0xFF3D0000), // Dark red accent
      ],
      'card': Colors.white.withOpacity(0.1),
      'text': Colors.white,
      'accent': const Color(0xFF8B0000),
      'border': Colors.white.withOpacity(0.2),
    };

    final colors = _isDarkMode ? darkColors : lightColors;

    // Update container decoration
    Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors['background'] as List<Color>,
        ),
      ),
      // ... rest of your container
    );

    // Update text styles
    Text(
      "Admin Dashboard",
      style: TextStyle(
        color: colors['text'] as Color,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );

    // Update card decorations
    Container(
      decoration: BoxDecoration(
        color: colors['card'] as Color,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: (colors['accent'] as Color).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isDarkMode ? 0.2 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNavButton(
          icon: Icons.arrow_back,
          label: 'Previous',
          onPressed: () {
            // Handle previous page
          },
        ),
        const SizedBox(width: 16),
        _buildNavButton(
          icon: Icons.home,
          label: 'Home',
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        const SizedBox(width: 16),
        _buildNavButton(
          icon: Icons.arrow_forward,
          label: 'Next',
          onPressed: () {
            // Handle next page
          },
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B0000).withOpacity(0.2),
            const Color(0xFF8B0000).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: TextButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome, Admin",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Admin Dashboard",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Refresh dashboard data
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Logout',
                    onPressed: () async {
                      await AdminService.logout();
                      if (!mounted) return;
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on DashboardService {}

class _MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget page;
  final String description;

  _MenuItem(this.title, this.icon, this.color, this.page, this.description);
}

class _MenuCard extends StatefulWidget {
  final _MenuItem menuItem;

  const _MenuCard(this.menuItem);

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Card(
          elevation: _isHovered ? 8 : 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.menuItem.icon,
                  size: 48,
                  color: widget.menuItem.color,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.menuItem.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.menuItem.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
      if (isHovered) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
}
