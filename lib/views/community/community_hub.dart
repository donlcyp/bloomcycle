import 'package:flutter/material.dart';
import '../../models/community_model.dart';
import '../../theme/design_system.dart';
import '../../theme/responsive_helper.dart';

class CommunityHubPage extends StatefulWidget {
  const CommunityHubPage({super.key});

  @override
  State<CommunityHubPage> createState() => _CommunityHubPageState();
}

class _CommunityHubPageState extends State<CommunityHubPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3FA),
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _selectedTab == 0
                ? _buildSurveysTab()
                : _buildChallengesTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == 0
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Symptom Surveys',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedTab == 0
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == 1
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Wellness Challenges',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedTab == 1
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveysTab() {
    final surveys = [
      SymptomSurvey(
        id: '1',
        symptom: 'Cramps',
        totalResponses: 2847,
        phaseDistribution: {
          'Menstruation': 2500,
          'Follicular': 200,
          'Ovulation': 100,
          'Luteal': 47,
        },
        averageSeverity: 6.8,
        userResponse: 'severe',
      ),
      SymptomSurvey(
        id: '2',
        symptom: 'Bloating',
        totalResponses: 2156,
        phaseDistribution: {
          'Menstruation': 800,
          'Follicular': 300,
          'Ovulation': 400,
          'Luteal': 656,
        },
        averageSeverity: 5.2,
        userResponse: 'moderate',
      ),
      SymptomSurvey(
        id: '3',
        symptom: 'Mood Changes',
        totalResponses: 3102,
        phaseDistribution: {
          'Menstruation': 600,
          'Follicular': 400,
          'Ovulation': 800,
          'Luteal': 1302,
        },
        averageSeverity: 6.1,
        userResponse: 'mild',
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: ResponsiveHelper.getHorizontalPadding(context),
        right: ResponsiveHelper.getHorizontalPadding(context),
        top: ResponsiveHelper.getVerticalPadding(context),
        bottom: ResponsiveHelper.getVerticalPadding(context) + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Surveys',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Compare your symptoms with the community',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...surveys.map((survey) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSurveyCard(survey),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSurveyCard(SymptomSurvey survey) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                survey.symptom,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${survey.totalResponses} responses',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Avg Severity: ${survey.averageSeverity.toStringAsFixed(1)}/10',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: survey.averageSeverity / 10,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFD946A6),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your Response: ${survey.userResponse}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    final challenges = [
      WellnessChallenge(
        id: '1',
        title: 'Hydration Week',
        description: 'Drink 8 glasses of water daily',
        category: 'Hydration',
        durationDays: 7,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        participantCount: 1247,
        userParticipating: true,
        userProgress: 0.71,
        rewards: ['Hydration Badge', '10 Points'],
      ),
      WellnessChallenge(
        id: '2',
        title: 'Movement Challenge',
        description: 'Exercise 30 minutes daily',
        category: 'Exercise',
        durationDays: 14,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 14)),
        participantCount: 892,
        userParticipating: false,
        userProgress: 0.0,
        rewards: ['Fitness Badge', '20 Points'],
      ),
      WellnessChallenge(
        id: '3',
        title: 'Sleep Wellness',
        description: 'Get 8 hours of sleep',
        category: 'Sleep',
        durationDays: 21,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 21)),
        participantCount: 2156,
        userParticipating: true,
        userProgress: 0.43,
        rewards: ['Sleep Badge', '30 Points'],
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: ResponsiveHelper.getHorizontalPadding(context),
        right: ResponsiveHelper.getHorizontalPadding(context),
        top: ResponsiveHelper.getVerticalPadding(context),
        bottom: ResponsiveHelper.getVerticalPadding(context) + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Challenges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Join challenges and earn rewards',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ...challenges.map((challenge) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildChallengeCard(challenge),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(WellnessChallenge challenge) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (challenge.userParticipating)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF51CF66).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Joined',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF51CF66),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${challenge.participantCount} participants',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '${challenge.durationDays} days',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (challenge.userParticipating) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${(challenge.userProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD946A6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.userProgress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFD946A6),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Joined ${challenge.title}!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Join Challenge',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
