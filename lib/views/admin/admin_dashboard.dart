import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedTab = 0;

  final List<String> _tabs = [
    'Overview',
    'Users',
    'Analytics',
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD946A6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'System Overview & Management',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFD946A6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFFD946A6)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Navigation
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _tabs.length,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == index
                                ? const Color(0xFFD946A6)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedTab == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _selectedTab == index
                              ? const Color(0xFFD946A6)
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                child: _buildTabContent(_selectedTab, screenWidth, screenHeight),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(int tabIndex, double screenWidth, double screenHeight) {
    switch (tabIndex) {
      case 0:
        return _buildOverviewTab(screenWidth, screenHeight);
      case 1:
        return _buildUsersTab(screenWidth, screenHeight);
      case 2:
        return _buildAnalyticsTab(screenWidth, screenHeight);
      default:
        return const SizedBox();
    }
  }

  // Overview Tab
  Widget _buildOverviewTab(double screenWidth, double screenHeight) {
    return Column(
      children: [
        // System Metrics
        _buildCard(
          title: 'System Metrics',
          subtitle: 'Overall system performance',
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: 0.85,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFD946A6),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status: Healthy', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  Text('Uptime: 99.8%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('Response: Good', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(child: _buildMetricBox('1,245', 'Active\nUsers', const Color(0xFFFF6B6B), screenHeight)),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(child: _buildMetricBox('892', 'Data\nRecords', const Color(0xFF4DABF7), screenHeight)),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(child: _buildMetricBox('98.5%', 'System\nHealth', const Color(0xFF10B981), screenHeight)),
                ],
              ),
            ],
          ),
          screenHeight: screenHeight,
        ),
        SizedBox(height: screenHeight * 0.02),
        // Recent Users
        _buildRecentUsersCard(screenWidth, screenHeight),
        SizedBox(height: screenHeight * 0.02),
        // Activity Log
        _buildActivityLogCard(screenWidth, screenHeight),
      ],
    );
  }

  // Users Tab
  Widget _buildUsersTab(double screenWidth, double screenHeight) {
    return Column(
      children: [
        _buildCard(
          title: 'User Statistics',
          subtitle: 'User management and analytics',
          child: Column(
            children: [
              _buildStatRow('Total Users', '1,245', Colors.blue),
              SizedBox(height: screenHeight * 0.015),
              _buildStatRow('Active Today', '312', Colors.green),
              SizedBox(height: screenHeight * 0.015),
              _buildStatRow('New Registrations', '45', Colors.orange),
              SizedBox(height: screenHeight * 0.015),
              _buildStatRow('Inactive Users', '89', Colors.red),
              SizedBox(height: screenHeight * 0.015),
              _buildStatRow('Premium Users', '234', const Color(0xFFD946A6)),
            ],
          ),
          screenHeight: screenHeight,
        ),
        SizedBox(height: screenHeight * 0.02),
        _buildCard(
          title: 'User Management',
          subtitle: 'Quick actions',
          child: Column(
            children: [
              _buildActionButton('View All Users', Icons.people, Colors.blue, screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _buildActionButton('Send Announcement', Icons.announcement, Colors.orange, screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _buildActionButton('Export User Data', Icons.download, Colors.green, screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _buildActionButton('Ban User', Icons.block, Colors.red, screenWidth),
            ],
          ),
          screenHeight: screenHeight,
        ),
      ],
    );
  }

  // Analytics Tab
  Widget _buildAnalyticsTab(double screenWidth, double screenHeight) {
    return Column(
      children: [
        _buildCard(
          title: 'Daily Active Users',
          subtitle: 'Last 7 days',
          child: Column(
            children: [
              _buildChartBar('Mon', 245, 300, Colors.blue, screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _buildChartBar('Tue', 312, 300, Colors.blue, screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _buildChartBar('Wed', 289, 300, Colors.blue, screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _buildChartBar('Thu', 335, 300, Colors.blue, screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _buildChartBar('Fri', 298, 300, Colors.blue, screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _buildChartBar('Sat', 267, 300, Colors.blue, screenWidth),
              SizedBox(height: screenHeight * 0.01),
              _buildChartBar('Sun', 241, 300, Colors.blue, screenWidth),
            ],
          ),
          screenHeight: screenHeight,
        ),
      ],
    );
  }

  // Helper widgets
  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget child,
    required double screenHeight,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          child,
        ],
      ),
    );
  }

  Widget _buildMetricBox(String value, String label, Color color, double screenHeight) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildRecentUsersCard(double screenWidth, double screenHeight) {
    final recentUsers = [
      {'name': 'Sarah Johnson', 'email': 'sarah@example.com', 'joined': '2 hours ago'},
      {'name': 'Emily Chen', 'email': 'emily@example.com', 'joined': '5 hours ago'},
      {'name': 'Alex Martinez', 'email': 'alex@example.com', 'joined': '1 day ago'},
    ];

    return _buildCard(
      title: 'Recent Users',
      subtitle: 'Latest registrations',
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentUsers.length,
        itemBuilder: (context, index) {
          final user = recentUsers[index];
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Color(0xFFD946A6), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        user['name']![0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(user['email']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(user['joined']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              if (index < recentUsers.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  child: Divider(color: Colors.grey[200]),
                ),
            ],
          );
        },
      ),
      screenHeight: screenHeight,
    );
  }

  Widget _buildActivityLogCard(double screenWidth, double screenHeight) {
    final activities = [
      {'action': 'User registered', 'time': '10:30 AM'},
      {'action': 'Data export completed', 'time': '10:15 AM'},
      {'action': 'System backup', 'time': '09:45 AM'},
      {'action': 'User login', 'time': '09:20 AM'},
    ];

    return _buildCard(
      title: 'Activity Log',
      subtitle: 'Recent activities',
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(color: Color(0xFFD946A6), shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(child: Text(activity['action']!, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                  Text(activity['time']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              if (index < activities.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: Divider(color: Colors.grey[200]),
                ),
            ],
          );
        },
      ),
      screenHeight: screenHeight,
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, double screenWidth) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: screenWidth * 0.03),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, int value, int maxValue, Color color, double screenWidth) {
    return Row(
      children: [
        SizedBox(width: 30, child: Text(label, style: const TextStyle(fontSize: 10))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / maxValue,
              minHeight: 24,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        SizedBox(width: 12),
        Text(value.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
