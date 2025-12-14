import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/splash/splash_screen.dart';
import 'services/firebase_service.dart';

// Global keys to avoid using BuildContext across async gaps
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initialize();

  // Hide status bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFEC4899),
      brightness: Brightness.light,
    ).copyWith(
      primary: const Color(0xFFEC4899),
      onPrimary: Colors.white,
      secondary: const Color(0xFF6366F1),
      onSecondary: Colors.white,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF1F2933),
    );

    final textTheme = GoogleFonts.poppinsTextTheme();

    return MaterialApp(
      title: 'BloomCycle',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: baseColorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: baseColorScheme.surface,
        textTheme: textTheme,
        primaryTextTheme: textTheme.copyWith(
          headlineSmall: textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white.withValues(alpha: 0.92),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            color: baseColorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: baseColorScheme.primary),
        ),
        cardTheme: CardThemeData(
          color: Colors.white.withValues(alpha: 0.94),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: baseColorScheme.primary.withValues(alpha: 0.08),
          surfaceTintColor: Colors.transparent,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: baseColorScheme.primary,
          contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: baseColorScheme.primary,
            foregroundColor: baseColorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: baseColorScheme.primary.withValues(alpha: 0.4)),
            foregroundColor: baseColorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: baseColorScheme.primary, width: 1.6),
          ),
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: Colors.black.withValues(alpha: 0.35),
          ),
          labelStyle: textTheme.bodySmall?.copyWith(
            color: Colors.black.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {'/home': (context) => const SplashScreen()},
    );
  }
}
