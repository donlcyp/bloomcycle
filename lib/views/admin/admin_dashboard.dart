import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedTab = 0;
  bool _isLoading = true;
  String? _currentUserId;

  // Data from Firebase
  Map<String, int> _userStats = {};
  List<Map<String, dynamic>> _recentUsers = [];
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _recentActivities = [];
  Map<String, int> _dailyActiveUsers = {};
  int _totalDataRecords = 0;

  final List<String> _tabs = ['Overview', 'Users', 'Analytics'];

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // First try to get current user's data (this should always work)
      final uid = _currentUserId;
      
      final results = await Future.wait([
        FirebaseService.getUserStats(currentUserId: uid),
        FirebaseService.getRecentUsers(limit: 5, currentUserId: uid),
        FirebaseService.getAllUsers(currentUserId: uid),
        FirebaseService.getRecentActivities(limit: 10),
        FirebaseService.getDailyActiveUsers(days: 7, currentUserId: uid),
        FirebaseService.getTotalDataRecords(currentUserId: uid),
      ]);
      
      if (mounted) {
        setState(() {
          _userStats = results[0] as Map<String, int>;
          _recentUsers = results[1] as List<Map<String, dynamic>>;
          _allUsers = results[2] as List<Map<String, dynamic>>;
          _recentActivities = results[3] as List<Map<String, dynamic>>;
          _dailyActiveUsers = results[4] as Map<String, int>;
          _totalDataRecords = results[5] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print('Admin dashboard error: $e');
      }
    }
  }

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
            child: const Icon(Icons.admin_panel_settings, color: Colors.white),
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
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD946A6),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFFD946A6),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02,
                        ),
                        child: _buildTabContent(
                          _selectedTab,
                          screenWidth,
                          screenHeight,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    int tabIndex,
    double screenWidth,
    double screenHeight,
  ) {
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
    final totalUsers = _userStats['totalUsers'] ?? 0;
    final activeToday = _userStats['activeToday'] ?? 0;
    final healthPercent = totalUsers > 0 ? (activeToday / totalUsers * 100).clamp(0, 100) : 0;
    
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
                  value: healthPercent / 100,
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
                    'Status: ${totalUsers > 0 ? "Healthy" : "No Data"}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  Text(
                    'Activity: ${healthPercent.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Response: Good',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricBox(
                      _formatNumber(totalUsers),
                      'Total\nUsers',
                      const Color(0xFFFF6B6B),
                      screenHeight,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: _buildMetricBox(
                      _formatNumber(_totalDataRecords),
                      'Data\nRecords',
                      const Color(0xFF4DABF7),
                      screenHeight,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: _buildMetricBox(
                      _formatNumber(activeToday),
                      'Active\nToday',
                      const Color(0xFF10B981),
                      screenHeight,
                    ),
                  ),
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  // Users Tab
  Widget _buildUsersTab(double screenWidth, double screenHeight) {
    final totalUsers = _userStats['totalUsers'] ?? 0;
    final activeToday = _userStats['activeToday'] ?? 0;
    final newThisWeek = _userStats['newThisWeek'] ?? 0;
    final inactiveUsers = totalUsers - activeToday;
    
    return Column(
      children: [
        _buildCard(
          title: 'User Statistics',
          subtitle: 'User management and analytics',
          child: Column(
            children: [
              _buildStatRow('Total Users', _formatNumber(totalUsers), Colors.blue),
              SizedBox(height: screenHeight * 0.015),
              _buildStatRow('Active Today', _formatNumber(activeToday), Colors.green),
              SizedBox(height: screenHeight * 0.015),
              _buildStatRow('New This Week', _formatNumber(newThisWeek), Colors.orange),
              SizedBox(height: screenHeight * 0.015),
              _buildStatRow('Inactive Users', _formatNumber(inactiveUsers.clamp(0, totalUsers)), Colors.red),
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
              _buildActionButton(
                'View All Users (${_allUsers.length})',
                Icons.people,
                Colors.blue,
                screenWidth,
                onTap: () => _showAllUsersDialog(),
              ),
              SizedBox(height: screenHeight * 0.01),
              _buildActionButton(
                'Refresh Data',
                Icons.refresh,
                Colors.orange,
                screenWidth,
                onTap: _loadData,
              ),
              SizedBox(height: screenHeight * 0.01),
              _buildActionButton(
                'Export User Data',
                Icons.download,
                Colors.green,
                screenWidth,
                onTap: () => _showExportDialog(),
              ),
            ],
          ),
          screenHeight: screenHeight,
        ),
        SizedBox(height: screenHeight * 0.02),
        // All Users List
        _buildAllUsersCard(screenWidth, screenHeight),
      ],
    );
  }

  void _showAllUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Users'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _allUsers.isEmpty
              ? const Center(child: Text('No users found'))
              : ListView.builder(
                  itemCount: _allUsers.length,
                  itemBuilder: (context, index) {
                    final user = _allUsers[index];
                    final name = user['displayName'] ?? user['name'] ?? 'Unknown';
                    final email = user['email'] ?? 'No email';
                    final createdAt = user['createdAt'] as DateTime?;
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFD946A6),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text(email),
                      trailing: createdAt != null
                          ? Text(
                              DateFormat('MMM d, y').format(createdAt),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            )
                          : null,
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final userDataStr = _allUsers.map((u) {
      final name = u['displayName'] ?? u['name'] ?? 'Unknown';
      final email = u['email'] ?? 'No email';
      return '$name, $email';
    }).join('\n');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Data Export'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Users: ${_allUsers.length}'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  userDataStr.isEmpty ? 'No data to export' : userDataStr,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAllUsersCard(double screenWidth, double screenHeight) {
    return _buildCard(
      title: 'All Users',
      subtitle: '${_allUsers.length} registered users',
      child: _allUsers.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No users found', style: TextStyle(color: Colors.grey)),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _allUsers.length > 10 ? 10 : _allUsers.length,
              itemBuilder: (context, index) {
                final user = _allUsers[index];
                final name = user['displayName'] ?? user['name'] ?? 'Unknown User';
                final email = user['email'] ?? 'No email';
                final createdAt = user['createdAt'] as DateTime?;
                final timeAgo = createdAt != null ? _getTimeAgo(createdAt) : 'Unknown';
                
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
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                                name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    if (index < (_allUsers.length > 10 ? 9 : _allUsers.length - 1))
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

  // Analytics Tab
  Widget _buildAnalyticsTab(double screenWidth, double screenHeight) {
    final maxValue = _dailyActiveUsers.values.isEmpty 
        ? 1 
        : _dailyActiveUsers.values.reduce((a, b) => a > b ? a : b);
    final chartMax = (maxValue * 1.2).ceil(); // Add 20% padding
    
    return Column(
      children: [
        _buildCard(
          title: 'Daily Active Users',
          subtitle: 'Last 7 days',
          child: _dailyActiveUsers.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No activity data available', style: TextStyle(color: Colors.grey)),
                  ),
                )
              : Column(
                  children: _dailyActiveUsers.entries.map((entry) {
                    return Column(
                      children: [
                        _buildChartBar(
                          entry.key,
                          entry.value,
                          chartMax > 0 ? chartMax : 1,
                          Colors.blue,
                          screenWidth,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                      ],
                    );
                  }).toList(),
                ),
          screenHeight: screenHeight,
        ),
        SizedBox(height: screenHeight * 0.02),
        _buildCard(
          title: 'Data Summary',
          subtitle: 'Overall statistics',
          child: Column(
            children: [
              _buildStatRow('Total Users', _formatNumber(_userStats['totalUsers'] ?? 0), Colors.blue),
              SizedBox(height: screenHeight * 0.015),
              _buildStatRow('Total Data Records', _formatNumber(_totalDataRecords), const Color(0xFF4DABF7)),
              SizedBox(height: screenHeight * 0.015),
              _buildStatRow('Active Today', _formatNumber(_userStats['activeToday'] ?? 0), Colors.green),
              SizedBox(height: screenHeight * 0.015),
              _buildStatRow('New This Week', _formatNumber(_userStats['newThisWeek'] ?? 0), Colors.orange),
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
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: screenHeight * 0.015),
          child,
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentUsersCard(double screenWidth, double screenHeight) {
    return _buildCard(
      title: 'Recent Users',
      subtitle: 'Latest registrations',
      child: _recentUsers.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No recent users', style: TextStyle(color: Colors.grey)),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentUsers.length,
              itemBuilder: (context, index) {
                final user = _recentUsers[index];
                final name = user['displayName'] ?? user['name'] ?? 'Unknown User';
                final email = user['email'] ?? 'No email';
                final createdAt = user['createdAt'] as DateTime?;
                final timeAgo = createdAt != null ? _getTimeAgo(createdAt) : 'Unknown';
                
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
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
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
                                name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    if (index < _recentUsers.length - 1)
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  Widget _buildActivityLogCard(double screenWidth, double screenHeight) {
    return _buildCard(
      title: 'Activity Log',
      subtitle: 'Recent activities',
      child: _recentActivities.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No recent activities', style: TextStyle(color: Colors.grey)),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentActivities.length,
              itemBuilder: (context, index) {
                final activity = _recentActivities[index];
                final action = activity['action'] ?? 'Unknown action';
                final timestamp = activity['timestamp'] as DateTime?;
                final time = timestamp != null 
                    ? DateFormat('h:mm a').format(timestamp)
                    : 'Unknown';
                
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
                            action,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    if (index < _recentActivities.length - 1)
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

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    double screenWidth, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(
    String label,
    int value,
    int maxValue,
    Color color,
    double screenWidth,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(label, style: const TextStyle(fontSize: 10)),
        ),
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
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
