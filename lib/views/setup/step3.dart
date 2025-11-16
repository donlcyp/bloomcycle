import 'package:flutter/material.dart';

class SetupStep3 extends StatefulWidget {
  const SetupStep3({super.key});

  @override
  State<SetupStep3> createState() => _SetupStep3State();
}

class _SetupStep3State extends State<SetupStep3> {
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
                      // Progress Indicators (moved below)
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
                              margin: const EdgeInsets.symmetric(horizontal: 8),
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
                              margin: const EdgeInsets.symmetric(horizontal: 8),
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
                        ],
                      ),
                    ],
                  ),
                ),
                // White Card
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
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD946A6),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Question Title
                      Center(
                        child: Text(
                          'Enable Location Access',
                          style: TextStyle(
                            fontSize: screenWidth > 600 ? 28 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Unlock the following features',
                          style: TextStyle(
                            fontSize: screenWidth > 600 ? 13 : 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Feature List
                      // Privacy Protection
                      _buildFeatureItem(
                        icon: Icons.lock,
                        title: 'Privacy Protection',
                        description:
                            'Your location data is encrypted and stored securely. No one but you can see your info',
                      ),
                      const SizedBox(height: 12),
                      // Recommended health recommendations
                      _buildFeatureItem(
                        icon: Icons.favorite,
                        title: 'Recommended health recommendations',
                        description:
                            'Get insights based on your local climate and health risks',
                      ),
                      const SizedBox(height: 12),
                      // Local healthcare provider suggestions
                      _buildFeatureItem(
                        icon: Icons.local_hospital,
                        title: 'Local healthcare provider suggestions',
                        description:
                            'Find nearby clinics and hospitals that may help you',
                      ),
                      const SizedBox(height: 12),
                      // Climate-based cycle insights
                      _buildFeatureItem(
                        icon: Icons.cloud,
                        title: 'Climate-based cycle insights',
                        description:
                            'Understand how weather patterns may affect your health',
                      ),
                      const SizedBox(height: 12),
                      // Emergency services locator
                      _buildFeatureItem(
                        icon: Icons.emergency,
                        title: 'Emergency services locator',
                        description:
                            'Quickly find nearby emergency services in your area',
                      ),
                      const SizedBox(height: 28),
                      // Enable Location Access Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD946A6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.location_on,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Enable Location Access',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Back Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Skip for now link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Skip to home
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Skipped to home'),
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

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFD946A6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
