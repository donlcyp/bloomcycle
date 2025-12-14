import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';
import '../views/nav/nav.dart';
import '../views/admin/admin_dashboard.dart';
import '../services/firebase_service.dart';
import '../services/google_sign_in_helper.dart';
import '../views/setup/step1.dart';
import '../state/user_state.dart';
import '../models/profile_model.dart';
import '../models/user_profile_data.dart';
import '../main.dart';
import '../theme/design_system.dart';

void _showTermsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Terms of Service',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Acceptance of Terms\n'
                'By using BloomCycle, you agree to these terms and conditions.\n\n'
                '2. Use License\n'
                'Permission is granted to temporarily download one copy of materials on BloomCycle for personal, non-commercial transitory viewing.\n\n'
                '3. Disclaimer\n'
                'The materials and information provided on BloomCycle are provided on an "as is" basis without warranties of any kind.\n\n'
                '4. Limitations of Liability\n'
                'In no event shall BloomCycle be liable for any direct, indirect, incidental, special, or consequential damages.\n\n'
                '5. Accuracy of Materials\n'
                'The materials appearing on BloomCycle could include technical, typographical, or photographic errors.\n\n'
                '6. Links\n'
                'BloomCycle has not reviewed all of the sites linked to its website and is not responsible for the contents of any such linked site.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

void _showPrivacyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Information Collection\n'
                'We collect information you provide directly, such as when you create an account or contact us.\n\n'
                '2. Use of Information\n'
                'Your information is used to provide, improve, and maintain BloomCycle services.\n\n'
                '3. Data Security\n'
                'We implement appropriate technical and organizational measures to protect your data.\n\n'
                '4. Third-Party Services\n'
                'BloomCycle may use third-party services for analytics and other functions.\n\n'
                '5. Your Rights\n'
                'You have the right to access, modify, or delete your personal information.\n\n'
                '6. Contact Us\n'
                'If you have questions about this privacy policy, please contact us at privacy@bloomcycle.com',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoggingIn = false;
  bool _isFacebookLoading = false;
  bool _isGoogleLoading = false;

  Future<void> _handlePostSignIn(User? user, {required String source}) async {
    if (user == null) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Authentication failed. Try again.')),
      );
      return;
    }

    final providerData = user.providerData.isNotEmpty
        ? user.providerData.first
        : null;

    final profileData = {
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
      'provider': source,
      'providerId': providerData?.providerId,
    };

    bool permissionDenied = false;

    try {
      await FirebaseService.createUser(user.uid, {
        'profile': profileData,
        'lastSignInAt': DateTime.now(),
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      permissionDenied = e.code == 'permission-denied';
      final message = permissionDenied
          ? 'We could not sync your profile because Firestore security rules blocked the write. Make sure authenticated users can read/write their own users/{uid} document.'
          : e.message ?? 'Failed to sync your profile.';
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to sync your profile: $e')),
      );
    }

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser == null) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Unable to complete sign-in. Please try again.'),
        ),
      );
      return;
    }

    if (!refreshedUser.emailVerified) {
      await refreshedUser.sendEmailVerification();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please verify your email. A verification link has been sent.',
          ),
        ),
      );

      await FirebaseAuth.instance.signOut();
      return;
    }

    Map<String, dynamic>? userRecord;
    try {
      userRecord = await FirebaseService.getUser(refreshedUser.uid);
    } on FirebaseException catch (e) {
      permissionDenied = permissionDenied || e.code == 'permission-denied';
      if (mounted) {
        final message = permissionDenied
            ? 'Unable to load your profile because Firestore security rules blocked the read.'
            : e.message ?? 'Unable to load your profile.';
        appScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        appScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Unable to load your profile: $e')),
        );
      }
    }

    final onboardingData =
        (userRecord?['onboarding'] as Map<String, dynamic>?) ?? {};
    final bool onboardingComplete = permissionDenied
        ? true
        : onboardingData['completed'] == true;

    if (!mounted) return;

    final destination = onboardingComplete
        ? const NavBar()
        : const SetupStep1();

    final profile = _toProfileModel(refreshedUser, userRecord);
    UserState.currentUser = UserProfileData(
      profile: profile,
      healthData: UserState.currentUser.healthData,
      settings: UserState.currentUser.settings,
      privacy: UserState.currentUser.privacy,
    );

    if (!context.mounted) return;
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }

  ProfileModel _toProfileModel(User user, Map<String, dynamic>? userRecord) {
    final profileMap = (userRecord?['profile'] as Map<String, dynamic>?) ?? {};
    final displayName =
        (profileMap['displayName'] as String?) ?? user.displayName ?? '';
    final parts = displayName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final email = (profileMap['email'] as String?) ?? user.email ?? '';
    final phone =
        (profileMap['phoneNumber'] as String?) ?? user.phoneNumber ?? '';
    final photoURL = (profileMap['photoURL'] as String?) ?? user.photoURL ?? '';
    final createdAt =
        (userRecord?['createdAt'] as DateTime?) ??
        user.metadata.creationTime ??
        DateTime.now();
    final cycleLength = (userRecord?['profile']?['cycleLength'] as int?) ?? 28;
    final location = (userRecord?['profile']?['location'] as String?) ?? '';
    final bio = (userRecord?['profile']?['bio'] as String?) ?? '';

    return ProfileModel(
      id: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phone,
      location: location,
      bio: bio,
      avatarUrl: photoURL,
      memberSince: createdAt,
      cycleLength: cycleLength,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await signInWithGoogleCredential();

      if (result == null) {
        if (!mounted) return;
        appScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Google sign-in cancelled.')),
        );
        return;
      }

      await _handlePostSignIn(result.userCredential.user, source: 'google');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google sign-in failed.')),
      );
    } catch (e) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Google sign-in error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isFacebookLoading = true;
    });

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      switch (result.status) {
        case LoginStatus.success:
          final AccessToken? accessToken = result.accessToken;
          if (accessToken == null) {
            if (!mounted) break;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Facebook login token missing.')),
            );
            break;
          }

          final credential = FacebookAuthProvider.credential(
            accessToken.tokenString,
          );
          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);

          await _handlePostSignIn(userCredential.user, source: 'facebook');
          break;
        case LoginStatus.cancelled:
          if (!mounted) break;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facebook login cancelled.')),
          );
          break;
        case LoginStatus.failed:
          if (!mounted) break;
          final message = result.message ?? 'Facebook login failed.';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          break;
        case LoginStatus.operationInProgress:
          break;
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Facebook login failed.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Facebook login error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isFacebookLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);
    final isLarge = media.size.width >= AppBreakpoints.tablet;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          ),
          _buildGlow(
            size: 260,
            alignment: const Alignment(-1.1, -1.0),
            color: AppColors.secondary,
          ),
          _buildGlow(
            size: 320,
            alignment: const Alignment(1.0, -0.1),
            color: AppColors.tertiary,
          ),
          _buildGlow(
            size: 280,
            alignment: const Alignment(-0.2, 1.1),
            color: Colors.white,
            opacity: 0.22,
          ),
          SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = constraints.maxWidth.clamp(340.0, 560.0);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 56,
                      horizontal: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: isLarge ? 120 : 96,
                            height: isLarge ? 120 : 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.soft(
                                color: Colors.white.withOpacity(0.18),
                                blur: 40,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/applogo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'BloomCycle',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Track your cycle with confidence',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.82),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 36),
                          GlassPanel(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLarge ? 40 : 26,
                              vertical: isLarge ? 36 : 28,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Log in to continue your journey',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  'Email address',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your email',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Password',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                        ),
                                        Text(
                                          'Remember me',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.secondary,
                                      ),
                                      child: const Text('Forgot password?'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLoggingIn
                                        ? null
                                        : () async {
                                            if (_emailController.text.isEmpty ||
                                                _passwordController
                                                    .text
                                                    .isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please enter both email and password.',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            setState(() {
                                              _isLoggingIn = true;
                                            });

                                            try {
                                              if (_emailController.text
                                                          .trim() ==
                                                      'admin@bloomcycle.com' &&
                                                  _passwordController.text ==
                                                      'admin123') {
                                                if (!mounted) return;

                                                Navigator.of(
                                                  context,
                                                ).pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const AdminDashboard(),
                                                  ),
                                                  (route) => false,
                                                );
                                                return;
                                              }

                                              final credential =
                                                  await FirebaseAuth.instance
                                                      .signInWithEmailAndPassword(
                                                        email: _emailController
                                                            .text
                                                            .trim(),
                                                        password:
                                                            _passwordController
                                                                .text,
                                                      );

                                              await _handlePostSignIn(
                                                credential.user,
                                                source: 'email',
                                              );
                                            } on FirebaseAuthException catch (
                                              e
                                            ) {
                                              String errorMessage =
                                                  'Login failed';
                                              if (e.code == 'user-not-found') {
                                                errorMessage =
                                                    'No account found with this email.';
                                              } else if (e.code ==
                                                  'wrong-password') {
                                                errorMessage =
                                                    'Incorrect password.';
                                              } else if (e.code ==
                                                  'invalid-email') {
                                                errorMessage =
                                                    'Invalid email address.';
                                              } else if (e.code ==
                                                  'user-disabled') {
                                                errorMessage =
                                                    'This account has been disabled.';
                                              } else {
                                                errorMessage =
                                                    e.message ?? 'Login failed';
                                              }

                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(errorMessage),
                                                ),
                                              );
                                            } finally {
                                              if (mounted) {
                                                setState(() {
                                                  _isLoggingIn = false;
                                                });
                                              }
                                            }
                                          },
                                    child: _isLoggingIn
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.4,
                                            ),
                                          )
                                        : const Text('Sign in'),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                OutlinedButton.icon(
                                  onPressed: _isGoogleLoading
                                      ? null
                                      : _signInWithGoogle,
                                  icon: _isGoogleLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF4285F4),
                                                ),
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/google.png',
                                          width: 20,
                                          height: 20,
                                        ),
                                  label: const Text('Continue with Google'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _isFacebookLoading
                                      ? null
                                      : _signInWithFacebook,
                                  icon: _isFacebookLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Icon(Icons.facebook),
                                  label: const Text('Continue with Facebook'),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    backgroundColor: const Color(0xFF1877F2),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Center(
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: theme.textTheme.bodySmall,
                                      children: [
                                        const TextSpan(
                                          text: "Don't have an account? ",
                                        ),
                                        TextSpan(
                                          text: 'Create one',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignupPage(),
                                                ),
                                              );
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                              children: [
                                const TextSpan(
                                  text: 'By signing in, you agree to our ',
                                ),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _showTermsDialog(context),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _showPrivacyDialog(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow({
    required double size,
    required Alignment alignment,
    required Color color,
    double opacity = 0.3,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}
