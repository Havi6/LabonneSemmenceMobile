import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../theme/app_colors.dart';

class MyBottomNavBar extends StatefulWidget {

  const MyBottomNavBar({super.key});
  @override
  State<MyBottomNavBar> createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  var _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final estSombre = themeProvider.isDarkMode;
    return SalomonBottomBar(
      backgroundColor: estSombre ? AppColors.backgroundDark : AppColors.backgroundLight,
      unselectedItemColor: estSombre ? Colors.white : Colors.black54,
      currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          // Home
          SalomonBottomBarItem(
              icon: Icon(Icons.home_rounded),
              title: Text("Acceuil"),
              selectedColor: AppColors.primary,
          ),

          //Enseignements

          SalomonBottomBarItem(
            icon: Icon(Icons.book_rounded),
            title: Text("Enseignements"),
            selectedColor: AppColors.primary,
          ),

          //Activitées ou calendrier

          SalomonBottomBarItem(
            icon: Icon(Icons.calendar_month_sharp),
            title: Text("Activitées"),
            selectedColor: AppColors.primary,
          ),

          //galeries

          SalomonBottomBarItem(
            icon: Icon(Icons.photo_camera),
            title: Text("Galerie"),
            selectedColor: AppColors.primary,
          ),
        ],);
  }
}
