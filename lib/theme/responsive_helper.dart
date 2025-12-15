import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileSmallWidth = 320;
  static const double mobileMediumWidth = 375;
  static const double mobileLargeWidth = 414;
  static const double tabletWidth = 768;

  static const double mobileSmallHeight = 568;
  static const double mobileMediumHeight = 667;
  static const double mobileLargeHeight = 812;
  static const double tabletHeight = 1024;

  static bool isMobileSmall(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  static bool isMobileMedium(BuildContext context) {
    return MediaQuery.of(context).size.width >= 360 &&
        MediaQuery.of(context).size.width < 414;
  }

  static bool isMobileLarge(BuildContext context) {
    return MediaQuery.of(context).size.width >= 414 &&
        MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 12;
    if (width < 414) return 16;
    if (width < 768) return 20;
    return 32;
  }

  static double getVerticalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 8;
    if (width < 414) return 12;
    if (width < 768) return 16;
    return 24;
  }

  static double getSpacing(
    BuildContext context, {
    double small = 8,
    double medium = 16,
    double large = 24,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return small;
    if (width < 414) return small + 2;
    if (width < 768) return medium;
    return large;
  }

  static double getFontSize(
    BuildContext context, {
    double small = 12,
    double medium = 14,
    double large = 16,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return small;
    if (width < 414) return small + 1;
    if (width < 768) return medium;
    return large;
  }

  static double getCardHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 80;
    if (width < 414) return 90;
    if (width < 768) return 100;
    return 120;
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return 1;
    if (width < 768) return 2;
    return 3;
  }

  static double getMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return width - 24;
    if (width < 414) return width - 32;
    if (width < 768) return width - 40;
    return 728;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final hPadding = getHorizontalPadding(context);
    final vPadding = getVerticalPadding(context);
    return EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding);
  }
}
