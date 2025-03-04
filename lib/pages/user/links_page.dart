import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserLinksPage extends StatelessWidget {
  const UserLinksPage({super.key});

  final _aaupLinks = const [
    {
      'name': 'AAUP Engineering',
      'url': 'https://sites.google.com/view/aaupeng/home',
      'icon': Icons.engineering,
      'category': 'Engineering',
      'isImportant': true,
    },
    {
      'name': 'AAUP Portal',
      'url': 'https://portal.aaup.edu',
      'icon': Icons.account_circle,
      'category': 'Main',
      'isImportant': true,
    },
    {
      'name': 'AAUP Website',
      'url': 'https://www.aaup.edu',
      'icon': Icons.language,
      'category': 'Main',
      'isImportant': true,
    },
    {
      'name': 'AAUP Moodle',
      'url': 'https://moodle.aaup.edu',
      'icon': Icons.school,
      'category': 'Learning',
      'isImportant': true,
    },
    {
      'name': 'AAUP Library',
      'url': 'https://library.aaup.edu',
      'icon': Icons.local_library,
      'category': 'Learning',
      'isImportant': true,
    },
  ];

  final _educationalLinks = const [
    {
      'name': 'Coursera',
      'url': 'https://www.coursera.org',
      'icon': Icons.laptop_mac,
      'category': 'Online Learning',
    },
    {
      'name': 'edX',
      'url': 'https://www.edx.org',
      'icon': Icons.video_library,
      'category': 'Online Learning',
    },
    {
      'name': 'Khan Academy',
      'url': 'https://www.khanacademy.org',
      'icon': Icons.play_circle_outline,
      'category': 'Online Learning',
    },
    {
      'name': 'MIT OpenCourseWare',
      'url': 'https://ocw.mit.edu',
      'icon': Icons.school_outlined,
      'category': 'Online Learning',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 158, 162, 201), // Light indigo
                  Color(0xFF0d47a1), // Rich blue
                  Color(0xFF01579b), // Dark blue
                ],
              ),
            ),
          ),
          title: const Text(
            'Important Links',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            tabs: [
              Tab(text: 'University Links'),
              Tab(text: 'External Links'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[100]!,
                Colors.white,
              ],
            ),
          ),
          child: TabBarView(
            children: [
              _buildAAUPLinksSection(),
              _buildEducationalLinksSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAAUPLinksSection() {
    return Builder(
      builder: (context) {
        // Group AAUP links by category
        final groupedLinks = <String, List<Map<String, dynamic>>>{};
        for (var link in _aaupLinks) {
          final category = link['category'] as String;
          groupedLinks[category] = [...(groupedLinks[category] ?? []), link];
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: groupedLinks.length,
          itemBuilder: (context, index) {
            final category = groupedLinks.keys.elementAt(index);
            final links = groupedLinks[category]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...links.map((link) => _buildLinkCard(context, link)),
                const Divider(height: 32),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEducationalLinksSection() {
    return Builder(
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _educationalLinks.length,
          itemBuilder: (context, index) {
            final link = _educationalLinks[index];
            return _buildLinkCard(context, link);
          },
        );
      },
    );
  }

  Widget _buildLinkCard(BuildContext context, Map<String, dynamic> link) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.link_rounded,
              color: const Color(0xFF1565C0),
              size: 24,
            ),
          ),
          title: Text(
            link['name'] ?? '',
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              link['url'] ?? '',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.qr_code),
                color: const Color(0xFF1565C0),
                onPressed: () => _showQRDialog(context, link),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new),
                color: const Color(0xFF1565C0),
                onPressed: () => _launchURL(link['url'] as String),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  void _showQRDialog(BuildContext context, Map<String, dynamic> link) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                link['name'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              QrImageView(
                data: link['url'] ?? '',
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
