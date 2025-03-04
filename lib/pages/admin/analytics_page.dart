// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../services/dashboard_service.dart';


class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage> {
  final DashboardService _dashboardService = DashboardService();
  final numberFormat = NumberFormat("#,##0");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF2B2B2B),
              Color(0xFF3D0000),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCards(),
              const SizedBox(height: 30),
              _buildChartsSection(),
              const SizedBox(height: 30),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardService.getDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data ?? {
          'adminLogins': 0,
          'totalUsers': 0,
          'totalMaterials': 0,
          'facultyMembers': 0,
        };

        return GridView.count(
          crossAxisCount: 2,  // Changed to 2 for better mobile layout
          shrinkWrap: true,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              "Admin Logins",
              numberFormat.format(stats['adminLogins']),
              Icons.admin_panel_settings,
              Colors.blue,
            ),
            _buildStatCard(
              "Total Users",
              numberFormat.format(stats['totalUsers']),
              Icons.people,
              Colors.green,
            ),
            _buildStatCard(
              "Materials",
              numberFormat.format(stats['totalMaterials']),
              Icons.book,
              Colors.orange,
            ),
            _buildStatCard(
              "Faculty",
              numberFormat.format(stats['facultyMembers']),
              Icons.school,
              Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      children: [
        _buildUserDistributionChart(),
        const SizedBox(height: 20),
        _buildWeeklyActivityChart(),
        const SizedBox(height: 20),
        _buildMaterialCategoriesChart(),
      ],
    );
  }

  Widget _buildUserDistributionChart() {
    return FutureBuilder<Map<String, int>>(
      future: _dashboardService.getUserTypeDistribution(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Card(
          color: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "User Distribution",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    dataMap: Map.fromEntries(
                      snapshot.data!.entries.map(
                        (e) => MapEntry(e.key, e.value.toDouble()),
                      ),
                    ),
                    chartRadius: MediaQuery.of(context).size.width / 2,
                    colorList: const [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                    ],
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    legendOptions: const LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
                      legendTextStyle: TextStyle(color: Colors.white),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValuesInPercentage: true,
                      chartValueStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMaterialCategoriesChart() {
    return Container(); // Placeholder
  }
  
  Widget _buildWeeklyActivityChart() {
    return Container(); // Placeholder
  }

  Widget _buildBottomSection() {
    return Row(
      children: [
        Expanded(child: Container()), // Placeholder
      ],
    );
  }

  // Add the remaining methods (_buildWeeklyActivityChart, _buildBottomSection, etc.)
  // from dashboard_screen.dart, adapting their styling to match the dark theme
} 