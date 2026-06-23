import 'package:flutter/material.dart';
import 'app_colors.dart';

// Theme provider
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// Custom Page Transition: Fade and Scale (Reveal effect)
class RevealPageTransitionsBuilder extends PageTransitionsBuilder {
  const RevealPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: child,
      ),
    );
  }
}

// Theme de l'app
class AppTheme {
  static final _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: const RevealPageTransitionsBuilder(),
      TargetPlatform.iOS: const RevealPageTransitionsBuilder(),
    },
  );

  // theme clair
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    pageTransitionsTheme: _pageTransitionsTheme,
    // Theme des textes
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 16),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
    ),
    // theme de l'appBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.primary,
      elevation: 2,
    ),
    // theme des icones
    iconTheme: IconThemeData(color: AppColors.primary),
    // style du drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.primary,
      scrimColor: AppColors.backgroundLight,
    ),
  );

  // theme sombre
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    pageTransitionsTheme: _pageTransitionsTheme,
    // theme de l'appBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.primary,
      elevation: 2,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    iconTheme: IconThemeData(color: AppColors.primary),
    // theme du drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.backgroundDark,
      scrimColor: AppColors.backgroundDark,
    ),
  );
}
