import 'package:flutter/material.dart';

/// Helper pour gérer la responsivité de l'application
class ResponsiveHelper {
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 360 && width < 768;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  static double getHorizontalPadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return 16.0;
    } else if (isMediumScreen(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  static double getFontSize(BuildContext context, {
    required double small,
    required double medium,
    required double large,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  static int getGridCrossAxisCount(BuildContext context, {
    int small = 2,
    int medium = 3,
    int large = 4,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  static double getIconSize(BuildContext context, {
    double small = 20.0,
    double medium = 24.0,
    double large = 28.0,
  }) {
    if (isSmallScreen(context)) {
      return small;
    } else if (isMediumScreen(context)) {
      return medium;
    } else {
      return large;
    }
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final horizontal = getHorizontalPadding(context);
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: 16.0,
    );
  }
}
