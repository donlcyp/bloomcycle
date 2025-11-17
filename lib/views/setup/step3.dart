import 'package:flutter/material.dart';
import 'step4.dart';

class SetupStep3 extends StatefulWidget {
  const SetupStep3({super.key});

  @override
  State<SetupStep3> createState() => _SetupStep3State();
}

class _SetupStep3State extends State<SetupStep3> {
  final Set<String> _selectedGoals = <String>{};
  final int _currentStep = 3;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMediumScreen = screenHeight < 900;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header with Logo and Progress
                Container(
                  margin: EdgeInsets.only(bottom: isMediumScreen ? 20 : 30),
                  child: Column(
                    children: [
                      // Logo and Title first
                      Text(
                        'BloomCycle',
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 28 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Track your cycle with confidence',
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 12 : 11,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      // Progress Indicators (1, 2, 3, 4)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Step 1 (Complete)
                          Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD946A6),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          // Progress Line
                          Expanded(
                            child: Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              color: const Color(0xFFD946A6),
                            ),
                          ),
                          // Step 2 (Complete)
                          Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD946A6),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          // Progress Line
                          Expanded(
                            child: Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              color: const Color(0xFFD946A6),
                            ),
                          ),
                          // Step 3 (Current)
                          Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD946A6),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$_currentStep',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth > 600 ? 16 : 14,
                                ),
                              ),
                            ),
                          ),
                          // Progress Line
                          Expanded(
                            child: Container(
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              color: Colors.grey[300],
                            ),
                          ),
                          // Step 4 (Incomplete)
                          Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '4',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // White Card - Health Goals
                Container(
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
                  padding: EdgeInsets.all(isMediumScreen ? 18 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Center Icon
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD946A6),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Question Title
                      const Center(
                        child: Text(
                          'Set Your Health Goals',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Choose what matters most to you so we can\nprovide personalized insights and\nrecommendations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Health Goals List
                      _buildGoalOption(
                        'Track menstrual cycle',
                        'Monitor periods, ovulation, and symptoms',
                      ),
                      const SizedBox(height: 16),
                      _buildGoalOption(
                        'Fertility planning',
                        'Optimize conception chances or prevent pregnancy',
                      ),
                      const SizedBox(height: 16),
                      _buildGoalOption(
                        'Overall wellness',
                        'Mood tracking, exercise, and nutrition insights',
                      ),
                      const SizedBox(height: 16),
                      _buildGoalOption(
                        'Symptom management',
                        'Track and understand PMS, cramps, and more',
                      ),
                      const SizedBox(height: 32),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _selectedGoals.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SetupStep4(),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD946A6),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Skip for now link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SetupStep4(),
                              ),
                            );
                          },
                          child: const Text(
                            'Skip for now',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD946A6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOption(String title, String description) {
    final isSelected = _selectedGoals.contains(title);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedGoals.remove(title);
          } else {
            _selectedGoals.add(title);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFD946A6) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFD946A6) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFD946A6) : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
