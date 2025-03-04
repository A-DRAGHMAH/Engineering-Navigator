import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/firebase_options.dart';
import 'config/theme.dart';
import 'pages/welcome_screen.dart';
import 'pages/user/user_home.dart';
import 'pages/user/hall_videos_page.dart';
import 'pages/admin/hall_videos_page.dart';
import 'services/notification_service.dart';
import 'pages/admin/admin_login.dart' as admin;
import 'pages/admin/admin_dashboard.dart' as dashboard;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'services/appwrite_service.dart';
import 'pages/user/notifications_page.dart';
import 'pages/user/user_programs.dart';
import 'pages/user/user_courses.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WebView
  WebViewPlatform.instance ??= AndroidWebViewPlatform();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize notification service
    await NotificationService.initialize();

    // Initialize Appwrite
    await AppwriteService.createAnonymousSession();

    // Run app
    runApp(const MyApp(initialThemeMode: false));
  } catch (e) {
    debugPrint('Error during initialization: $e');
    // Run app with default light theme if initialization fails
    runApp(const MyApp(initialThemeMode: false));
  }
}

class MyApp extends StatefulWidget {
  final bool initialThemeMode;

  const MyApp({
    super.key,
    this.initialThemeMode = false,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialThemeMode;
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing preferences: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> toggleTheme() async {
    try {
      setState(() {
        _isDarkMode = !_isDarkMode;
      });
      await _prefs.setBool('isDarkMode', _isDarkMode);
      debugPrint('Theme toggled: isDarkMode = $_isDarkMode');
    } catch (e) {
      debugPrint('Error toggling theme: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NotificationService.navigatorKey,
      title: 'Engineering Navigator App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(
              onThemeToggle: toggleTheme,
              isDarkMode: _isDarkMode,
            ),
        '/notifications': (context) => const UserNotificationsPage(),
        '/admin': (context) => const admin.AdminLoginPage(),
        '/admin/dashboard': (context) => const dashboard.AdminDashboard(),
        '/admin/hall-videos': (context) => const AdminHallVideosPage(),
        '/user': (context) => UserHomePage(
              onThemeToggle: toggleTheme,
              isDarkMode: _isDarkMode,
            ),
        '/user/hall-videos': (context) => const UserHallVideosPage(),
        '/user/programs': (context) => const UserProgramsPage(),
        '/user/courses': (context) => const UserCoursesPage(),
      },
      onGenerateRoute: (settings) {
        // Handle unknown routes
        return MaterialPageRoute(
          builder: (context) => WelcomeScreen(
            onThemeToggle: toggleTheme,
            isDarkMode: _isDarkMode,
          ),
        );
      },
    );
  }
}
