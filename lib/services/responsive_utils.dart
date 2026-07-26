import 'package:flutter/material.dart';

extension ResponsiveUtils on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
  bool get isLandscape => screenWidth > screenHeight;

  double percentWidth(double percent) => screenWidth * (percent / 100);
  double percentHeight(double percent) => screenHeight * (percent / 100);

  double get pageHorizontalPadding => responsiveValue(
    mobile: screenWidth < 360 ? 16.0 : 20.0,
    tablet: 32.0,
    desktop: 48.0,
  );

  double get verticalSpacing => isLandscape ? 12.0 : 24.0;
  double get sectionSpacing => isLandscape ? 16.0 : 32.0;

  double get formMaxWidth =>
      responsiveValue(mobile: double.infinity, tablet: 560.0, desktop: 640.0);

  double get bottomNavigationClearance => isLandscape 
      ? 80.0 
      : responsiveValue(mobile: 104.0, tablet: 116.0, desktop: 124.0);

  // Helper for responsive values
  T responsiveValue<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}
