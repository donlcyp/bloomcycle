import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFEC4899);
  static const Color secondary = Color(0xFF6366F1);
  static const Color tertiary = Color(0xFF22D3EE);
  static const Color background = Color(0xFFFDF2F8);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2933);
  static const Color textMuted = Color(0xFF6B7280);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFE5E9C), Color(0xFF7B61FF)],
  );

  static LinearGradient glassGradient([double opacity = 0.18]) =>
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: opacity + 0.08),
          Colors.white.withValues(alpha: opacity),
        ],
      );
}

class AppShadows {
  static List<BoxShadow> soft({Color? color, double blur = 32}) => [
    BoxShadow(
      color: (color ?? AppColors.primary).withValues(alpha: 0.12),
      blurRadius: blur,
      spreadRadius: 0,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> insetLight() => [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.9),
      blurRadius: 16,
      spreadRadius: -12,
    ),
  ];
}

class AppBreakpoints {
  static const double tablet = 768;
  static const double desktop = 1140;
}

class AppTextStyles {
  static TextStyle heading(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineMedium!
      .copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle labelSmall(BuildContext context) => Theme.of(context)
      .textTheme
      .labelSmall!
      .copyWith(color: AppColors.textMuted, letterSpacing: 0.3);
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    this.child,
    this.padding,
    this.borderRadius = 24,
    this.opacity = 0.18,
    this.borderColor,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double opacity;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.glassGradient(opacity),
            border: Border.all(
              color: (borderColor ?? Colors.white).withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: AppShadows.soft(
              color: AppColors.secondary.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}
