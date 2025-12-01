import 'package:flutter/material.dart';
import '../models/home_data.dart';
import 'chat/health_chat.dart';
import 'logs/symptoms_log.dart';
import 'logs/mood_log.dart';
import 'logs/notes_log.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              // Cycle Overview Section
              _buildCycleOverview(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.03),
              // Quick Actions Section
              _buildQuickActions(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.03),
              // Today's Insights Section
              _buildTodaysInsights(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.03),
              // Today's Tip Section
              _buildTodaysTip(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.03),
              // Health Tips Section
              _buildHealthTips(screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.03),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const HealthChatPage()),
          );
        },
        backgroundColor: const Color(0xFFD946A6),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Health tips'),
      ),
    );
  }

  Widget _buildCycleOverview(double screenWidth, double screenHeight) {
    final data = HomeData.cycleData;
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
            'Cycle Overview',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Current cycle: ${data.totalCycleDays} days',
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
                  value: data.cycleProgress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFD946A6),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              // Timeline labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Day 1',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  Text(
                    'Day ${data.currentDay} (Today)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Day ${data.totalCycleDays}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          // Cycle Info Boxes
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildCycleInfoBoxNew(
                    '${data.currentDay}',
                    'Current\nDay',
                    const Color(0xFFFF6B6B),
                    screenHeight,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: _buildCycleInfoBoxNew(
                    '${data.daysLeft}',
                    'Days to\nPeriod',
                    const Color(0xFF4DABF7),
                    screenHeight,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: _buildCycleInfoBoxNew(
                    data.currentPhase,
                    'Current\nPhase',
                    const Color(0xFF51CF66),
                    screenHeight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleInfoBoxNew(
    String title,
    String subtitle,
    Color color,
    double screenHeight,
  ) {
    return Container(
      height: 115,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(double screenWidth, double screenHeight) {
    final actions = HomeData.quickActions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.02),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        ...actions.asMap().entries.map((entry) {
          final action = entry.value;
          final showPrediction =
              entry.key > 0; // Show prediction for Symptoms and Mood
          VoidCallback onTap;
          final titleLower = action.title.toLowerCase();
          if (titleLower.contains('period')) {
            onTap = () {
              // In a full app, you might navigate to the Calendar tab here.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Open Calendar to log today\'s period.'),
                ),
              );
            };
          } else if (titleLower.contains('symptom')) {
            onTap = () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SymptomsLogPage(),
                ),
              );
            };
          } else if (titleLower.contains('mood')) {
            onTap = () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MoodLogPage()),
              );
            };
          } else if (titleLower.contains('note')) {
            onTap = () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const NotesLogPage()),
              );
            };
          } else {
            onTap = () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Action: ${action.title}')),
              );
            };
          }
          return Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.015),
            child: _buildActionCard(
              action.title,
              _getIconData(action.iconName),
              Color(action.colorValue),
              showPrediction,
              onTap,
            ),
          );
        }),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'description':
        return Icons.description;
      case 'favorite':
        return Icons.favorite;
      case 'emoji_emotions':
        return Icons.emoji_emotions;
      default:
        return Icons.circle;
    }
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    bool showPrediction,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              if (showPrediction) ...[
                const SizedBox(width: 8),
                Text(
                  '(prediction)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysInsights(double screenWidth, double screenHeight) {
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
            'Today\'s Insights',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD946A6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wb_sunny,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ovulation Phase Active',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your fertility window is at its peak. Consider tracking basal body temperature for more accurate predictions.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysTip(double screenWidth, double screenHeight) {
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
            'Today\'s Tip',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD946A6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hydration Focus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'During ovulation, increase your water intake to support cervical mucus production and overall reproductive health.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTips(double screenWidth, double screenHeight) {
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
            'Health Tips',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          _buildHealthTipCard(
            'Ovulation Nutrition',
            'Focus on antioxidant-rich foods like berries and leafy greens during your fertile window.',
            Icons.restaurant,
            const Color(0xFFFCE7F3),
            const Color(0xFFD946A6),
          ),
          SizedBox(height: screenHeight * 0.015),
          _buildHealthTipCard(
            'Exercise Tip',
            'Light cardio and yoga are perfect for your current cycle phase.',
            Icons.fitness_center,
            const Color(0xFFDBEAFE),
            const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTipCard(
    String title,
    String description,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
