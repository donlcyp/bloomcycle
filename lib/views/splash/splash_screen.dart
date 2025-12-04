import 'package:flutter/material.dart';
import '../../auth/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _nameController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _nameOpacity;
  late Animation<Offset> _nameSlide;
  late Animation<double> _floatingOffset;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Name animation controller
    _nameController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _nameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _nameController, curve: Curves.easeIn),
    );

    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _nameController, curve: Curves.easeOut),
    );

    // Floating animation (continuous)
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatingOffset = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Pulse animation (continuous)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startSplashSequence() async {
    // Step 1: Animate logo
    await _logoController.forward();
    
    // Step 2: Animate name (after 500ms)
    await Future.delayed(const Duration(milliseconds: 500));
    _nameController.forward();

    // Step 3: Navigate to login (after 2s)
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _nameController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return CustomPaint(
                painter: AnimatedGradientPainter(
                  offset: _floatingController.value,
                ),
                size: Size(screenWidth, screenHeight),
              );
            },
          ),
          // Main content
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _logoController,
                _nameController,
                _floatingController,
                _pulseController,
              ]),
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decorative floating circles
                    if (_logoOpacity.value > 0)
                      Opacity(
                        opacity: _logoOpacity.value * 0.3,
                        child: Transform.translate(
                          offset: Offset(0, _floatingOffset.value),
                          child: Container(
                            width: screenWidth * 0.08,
                            height: screenWidth * 0.08,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD946A6),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD946A6)
                                      .withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: screenHeight * 0.04),
                    // Logo with pulse glow
                    Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulse glow background
                            Transform.scale(
                              scale: _pulseScale.value,
                              child: Container(
                                width: screenWidth * 0.25,
                                height: screenWidth * 0.25,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD946A6)
                                      .withOpacity(0.2),
                                  shape: BoxShape.circle,
                              ),
                              ),
                            ),
                            // Main logo container
                            Container(
                              width: screenWidth * 0.25,
                              height: screenWidth * 0.25,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD946A6),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD946A6)
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/applogo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.06),
                    // Decorative floating circle (right)
                    if (_logoOpacity.value > 0.5)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.1),
                          child: Opacity(
                            opacity: _logoOpacity.value * 0.3,
                            child: Transform.translate(
                              offset: Offset(0, -_floatingOffset.value),
                              child: Container(
                                width: screenWidth * 0.06,
                                height: screenWidth * 0.06,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD946A6),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD946A6)
                                        .withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // App name with animation
                    SlideTransition(
                      position: _nameSlide,
                      child: Opacity(
                        opacity: _nameOpacity.value,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    const Color(0xFFD946A6),
                                    const Color(0xFFEC4899),
                                  ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                'BloomCycle',
                                style: TextStyle(
                                  fontSize: screenWidth > 600 ? 36 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'Track Your Cycle With Ease',
                              style: TextStyle(
                                fontSize: screenWidth > 600 ? 14 : 12,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for animated background gradient
class AnimatedGradientPainter extends CustomPainter {
  final double offset;

  AnimatedGradientPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF5E6E8),
          Color.lerp(const Color(0xFFF5E6E8), const Color(0xFFEFCCD6), offset)!,
          const Color(0xFFF5E6E8),
        ],
        stops: [
          0.0,
          0.5 + (offset * 0.2),
          1.0,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(AnimatedGradientPainter oldDelegate) {
    return oldDelegate.offset != offset;
  }
}
