import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.08,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            // Admin Header
            _buildAdminHeader(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
            // Cycle Overview Section
            _buildCycleOverview(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
            // User Statistics Section
            _buildUserStatistics(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
            // System Health Section
            _buildSystemHealth(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
            // Recent Users Section
            _buildRecentUsers(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
            // Activity Log Section
            _buildActivityLog(screenWidth, screenHeight),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminHeader(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'System Overview & Management',
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 12 : 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFD946A6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCycleOverview(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Metrics',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Overall system performance',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 12 : 11,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          // Progress Bar with Timeline
          Column(
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
                  Text(
                    'Status: Healthy',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Uptime: 99.8%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Response: Good',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          // Admin Metrics Boxes
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  '1,245',
                  'Active\nUsers',
                  const Color(0xFFFF6B6B),
                  screenHeight,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _buildMetricBox(
                  '892',
                  'Data\nRecords',
                  const Color(0xFF4DABF7),
                  screenHeight,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _buildMetricBox(
                  '98.5%',
                  'System\nHealth',
                  const Color(0xFF10B981),
                  screenHeight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(
    String value,
    String label,
    Color color,
    double screenHeight,
  ) {
    return Container(
      height: 120,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: screenHeight * 0.015,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatistics(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Statistics',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          _buildStatRow('Total Users', '1,245', Colors.blue),
          SizedBox(height: screenHeight * 0.01),
          _buildStatRow('Active Today', '312', Colors.green),
          SizedBox(height: screenHeight * 0.01),
          _buildStatRow('New Registrations', '45', Colors.orange),
          SizedBox(height: screenHeight * 0.01),
          _buildStatRow('Inactive Users', '89', Colors.red),
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
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemHealth(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Health',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          _buildHealthMetric('Database', 98, Colors.green),
          SizedBox(height: screenHeight * 0.01),
          _buildHealthMetric('API Server', 95, Colors.green),
          SizedBox(height: screenHeight * 0.01),
          _buildHealthMetric('Cache', 87, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(String name, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 6,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentUsers(double screenWidth, double screenHeight) {
    final recentUsers = [
      {'name': 'Sarah Johnson', 'email': 'sarah@example.com', 'joined': '2 hours ago'},
      {'name': 'Emily Chen', 'email': 'emily@example.com', 'joined': '5 hours ago'},
      {'name': 'Alex Martinez', 'email': 'alex@example.com', 'joined': '1 day ago'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Users',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ListView.builder(
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFD946A6),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            user['name']![0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name']!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user['email']!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        user['joined']!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (index < recentUsers.length - 1)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      child: Divider(color: Colors.grey[200]),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog(double screenWidth, double screenHeight) {
    final activities = [
      {'action': 'User registered', 'time': '10:30 AM'},
      {'action': 'Data export completed', 'time': '10:15 AM'},
      {'action': 'System backup', 'time': '09:45 AM'},
      {'action': 'User login', 'time': '09:20 AM'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Log',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ListView.builder(
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFD946A6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Text(
                          activity['action']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        activity['time']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
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
        ],
      ),
    );
  }
}
