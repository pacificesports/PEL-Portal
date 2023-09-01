import 'package:flutter/material.dart';

class LayoutHelper {
  static const double _desktopContentWidth = 1400;
  static const double _desktopPadding = 32;

  static const double _mobileMaxWidth = 600;
  static const double _mobilePadding = 8;

  static double width(context) => MediaQuery.of(context).size.width;
  static double height(context) => MediaQuery.of(context).size.height;

  static double getContentWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < _mobileMaxWidth;
    return isMobile ? screenWidth : _desktopContentWidth;
  }

  static EdgeInsets getPadding(BuildContext context) {
    return EdgeInsets.all(getPaddingDouble(context));
  }

  static double getPaddingDouble(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < _mobileMaxWidth;
    return isMobile ? _mobilePadding : _desktopPadding;
  }
}
