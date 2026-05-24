import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double compactPhone = 360;
  static const double compactContent = 380;
  static const double narrowContent = 430;
  static const double phone = 700;
  static const double tablet = 800;

  static bool isCompactWidth(double width) {
    return width < compactPhone;
  }

  static bool isPhoneWidth(double width) {
    return width < phone;
  }

  static bool isCompactContentWidth(double width) {
    return width < compactContent;
  }

  static bool isNarrowContentWidth(double width) {
    return width < narrowContent;
  }

  static bool isDesktopWidth(double width) {
    return width >= tablet;
  }

  static bool isCompact(BuildContext context) {
    return isCompactWidth(MediaQuery.sizeOf(context).width);
  }
}
