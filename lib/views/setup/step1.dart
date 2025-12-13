import 'package:flutter/material.dart';
import '../../main.dart';
import 'step2.dart';
import '../../state/user_state.dart';

class SetupStep1 extends StatefulWidget {
  const SetupStep1({super.key});

  @override
  State<SetupStep1> createState() => _SetupStep1State();
}

class _SetupStep1State extends State<SetupStep1> {
  final _dobController = TextEditingController();

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

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
                // White Card with Header and Content
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(isMediumScreen ? 20 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header (Logo, Title, Subtitle, Progress)
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/logo1.png',
                              width: screenWidth * 0.16,
                              height: screenWidth * 0.16,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: screenHeight * 0.02),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Step 1 (Current)
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD946A6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '1',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Line between 1 and 2
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                    ),
                                    color: Colors.grey[300],
                                  ),
                                ),
                                // Step 2
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '2',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Line between 2 and 3
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                    ),
                                    color: Colors.grey[300],
                                  ),
                                ),
                                // Step 3
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '3',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Line between 3 and 4
                                Expanded(
                                  child: Container(
                                    height: 2,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                    ),
                                    color: Colors.grey[300],
                                  ),
                                ),
                                // Step 4
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
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
                      const SizedBox(height: 32),
                      // Question Title
                      const Text(
                        "What's your birth date?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This helps us provide personalized insights',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      // Date of Birth Label
                      const Text(
                        'Date of Birth',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Date Picker Field
                      TextField(
                        controller: _dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select your birth date',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD946A6),
                              width: 2,
                            ),
                          ),
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: 20,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1960),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _dobController.text =
                                  '${picked.month}/${picked.day}/${picked.year}';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 28),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _dobController.text.isEmpty
                              ? null
                              : () {
                                  // Store DOB in user state
                                  try {
                                    final parts = _dobController.text.split(
                                      '/',
                                    ); // M/D/YYYY
                                    if (parts.length == 3) {
                                      final month = int.parse(parts[0]);
                                      final day = int.parse(parts[1]);
                                      final year = int.parse(parts[2]);
                                      UserState.dateOfBirth = DateTime(
                                        year,
                                        month,
                                        day,
                                      );
                                    }
                                  } catch (_) {}

                                  appScaffoldMessengerKey.currentState?.showSnackBar(
                                    const SnackBar(
                                      content: Text('Birth date saved.'),
                                    ),
                                  );

                                  // Navigate to step 2
                                  appNavigatorKey.currentState?.push(
                                    MaterialPageRoute(
                                      builder: (context) => const SetupStep2(),
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
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
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
}
