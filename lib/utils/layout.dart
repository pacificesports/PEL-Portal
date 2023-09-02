import 'package:flutter/material.dart';

class LayoutHelper {
  static const double _desktopContentWidth = 1400;
  static const double _desktopPadding = 32;

  static const double _mobileMaxWidth = 600;
  static const double _mobilePadding = 8;

  static double width(context) => MediaQuery.of(context).size.width;
  static double height(context) => MediaQuery.of(context).size.height;

  // Helper functions for getting padding
  static EdgeInsets p(context) => getPadding(context);
  static EdgeInsets hp(context) => getHalfPadding(context);
  static double pd(context) => getPaddingDouble(context);
  static double hpd(context) => getHalfPaddingDouble(context);

  static bool isMobile(context) => width(context) < _mobileMaxWidth;

  static double getContentWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < _mobileMaxWidth;
    return isMobile ? screenWidth : _desktopContentWidth;
  }

  static EdgeInsets getPadding(BuildContext context) {
    return EdgeInsets.all(getPaddingDouble(context));
  }

  static EdgeInsets getHalfPadding(BuildContext context) {
    return EdgeInsets.all(getPaddingDouble(context) / 2);
  }

  static double getPaddingDouble(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < _mobileMaxWidth;
    return isMobile ? _mobilePadding : _desktopPadding;
  }

  static double getHalfPaddingDouble(BuildContext context) {
    return getPaddingDouble(context) / 2;
  }
}

