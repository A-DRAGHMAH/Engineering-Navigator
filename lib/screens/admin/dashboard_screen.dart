// ignore_for_file: deprecated_member_use

import 'package:aaup/models/dashboard_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' hide PieChart;
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../services/dashboard_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DashboardService _dashboardService = DashboardService();
  final numberFormat = NumberFormat("#,##0");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStatCards(),
            const SizedBox(height: 30),
            _buildChartsSection(),
            const SizedBox(height: 30),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Admin Dashboard",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              // Refresh dashboard data
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return FutureBuilder<DashboardData>(
      future: _dashboardService.getDashboardStats().then((data) {
        // Convert Map<String, dynamic> to DashboardData
        return DashboardData(
          adminLogins: data['adminLogins'] as int,
          totalUsers: data['totalUsers'] as int,
          totalMaterials: data['totalMaterials'] as int,
          facultyMembers: data['facultyMembers'] as int,
        );
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data ??
            DashboardData(
              adminLogins: 0,
              totalUsers: 0,
              totalMaterials: 0,
              facultyMembers: 0,
            );

        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              "Admin Logins",
              numberFormat.format(stats.adminLogins),
              Icons.admin_panel_settings,
              const Color(0xFF8B0000),
            ),
            _buildStatCard(
              "Total Users",
              numberFormat.format(stats.totalUsers),
              Icons.people,
              const Color(0xFF990000),
            ),
            _buildStatCard(
              "Materials",
              numberFormat.format(stats.totalMaterials),
              Icons.book,
              const Color(0xFFA50000),
            ),
            _buildStatCard(
              "Faculty",
              numberFormat.format(stats.facultyMembers),
              Icons.school,
              const Color(0xFFB20000),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.w500,
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
        Row(
          children: [
            Expanded(child: _buildUserDistributionChart()),
            const SizedBox(width: 16),
            Expanded(child: _buildMaterialCategoriesChart()),
          ],
        ),
        const SizedBox(height: 20),
        _buildWeeklyActivityChart(),
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
          elevation: 4,
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
                    chartRadius: 200,
                    centerText: "Users",
                    chartType: ChartType.ring,
                    ringStrokeWidth: 32,
                    legendOptions: const LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
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

  Widget _buildWeeklyActivityChart() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dashboardService.getWeeklyActivity(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekly Activity",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: data.isEmpty
                          ? 10
                          : data
                                  .map((e) => e['count'] as num)
                                  .reduce((a, b) => a > b ? a : b) *
                              1.2,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value >= data.length) {
                                return const Text('');
                              }
                              final date =
                                  DateTime.parse(data[value.toInt()]['date']);
                              return Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: data.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value['count'].toDouble(),
                              color: Theme.of(context).primaryColor,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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

  Widget _buildBottomSection() {
    return Row(
      children: [
        Expanded(
          child: _buildTopMaterialsCard(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRecentActivityCard(),
        ),
      ],
    );
  }

  Widget _buildTopMaterialsCard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dashboardService.getTopMaterials(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final materials = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Top Materials",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...materials.map((material) => _buildMaterialItem(
                    material['name'],
                    "${material['downloads']} downloads",
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaterialItem(String name, String downloads) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            downloads,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dashboardService.getRecentActivity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final activities = snapshot.data ?? [];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ...activities.map((activity) {
                final timestamp = activity['timestamp'] as Timestamp;
                final timeAgo = _getTimeAgo(timestamp.toDate());
                return _buildActivityItem(
                  activity['activity'],
                  timeAgo,
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(String activity, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              activity,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildMaterialCategoriesChart() {
    return FutureBuilder<Map<String, int>>(
      future: _dashboardService.getMaterialCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        if (data.isEmpty) {
          return const Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No materials data available'),
              ),
            ),
          );
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Material Categories",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    dataMap: Map.fromEntries(
                      data.entries.map(
                        (e) => MapEntry(e.key, e.value.toDouble()),
                      ),
                    ),
                    animationDuration: const Duration(milliseconds: 800),
                    chartLegendSpacing: 32,
                    chartRadius: MediaQuery.of(context).size.width / 6,
                    colorList: const [
                      Colors.blue,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.red,
                      Colors.teal,
                    ],
                    initialAngleInDegree: 0,
                    chartType: ChartType.disc,
                    legendOptions: const LegendOptions(
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
                      showLegends: true,
                      legendTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    chartValuesOptions: const ChartValuesOptions(
                      showChartValueBackground: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValuesOutside: false,
                      decimalPlaces: 1,
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
}
