import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/pages/about_us_page.dart';
import 'package:la_bonne_semence_mobile/pages/account_page.dart';
import 'package:la_bonne_semence_mobile/pages/admin_page.dart';
import 'package:la_bonne_semence_mobile/pages/calendar_page.dart';
import 'package:la_bonne_semence_mobile/pages/contact_page.dart';
import 'package:la_bonne_semence_mobile/pages/donnation_page.dart';
import 'package:la_bonne_semence_mobile/pages/galery_page.dart';
import 'package:la_bonne_semence_mobile/pages/home_page.dart';
import 'package:la_bonne_semence_mobile/pages/sermons_page.dart';
import 'package:la_bonne_semence_mobile/pages/setting_page.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';
import 'package:la_bonne_semence_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../theme/app_colors.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int _currentIndex = 0;
  int? _selectedDrawerIndex;
  bool _isDisplayingDrawerPage = false;

  late final List<Widget> _bottomPages;

  final List<Widget> _drawerPages = const [
    DonnationPage(),
    ContactPage(),
    AboutUsPage(),
    Profile(),
    SettingPage(),
    AdminPage(),
  ];

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
      _isDisplayingDrawerPage = false;
      _selectedDrawerIndex = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _bottomPages = [
      HomePage(onNavigate: _onNavigate),
      const SermonsPage(),
      const CalendarPage(),
      const GaleryPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentBody = _isDisplayingDrawerPage
        ? _drawerPages[_selectedDrawerIndex ?? 0]
        : _bottomPages[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.church_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              'La Bonne Semence',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(context, isDark, themeProvider),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(
            _isDisplayingDrawerPage
                ? 'drawer_$_selectedDrawerIndex'
                : 'bottom_$_currentIndex',
          ),
          child: currentBody,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context, isDark),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    bool isDark,
    ThemeProvider themeProvider,
  ) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final items = <({IconData icon, IconData selectedIcon, String label})>[
      (
        icon: Icons.volunteer_activism_outlined,
        selectedIcon: Icons.volunteer_activism,
        label: 'Dons',
      ),
      (
        icon: Icons.contact_support_outlined,
        selectedIcon: Icons.contact_support,
        label: 'Contact',
      ),
      (icon: Icons.info_outline, selectedIcon: Icons.info, label: 'À propos'),
      (
        icon: Icons.account_circle_outlined,
        selectedIcon: Icons.account_circle,
        label: 'Compte',
      ),
      (
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: 'Paramètres',
      ),
      (
        icon: Icons.admin_panel_settings_outlined,
        selectedIcon: Icons.admin_panel_settings,
        label: 'Admin',
      ),
    ];

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                children: [
                  const Icon(Icons.church_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'La Bonne Semence',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: isDark
                        ? 'Activer le thème clair'
                        : 'Activer le thème sombre',
                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    color: AppColors.primary,
                    onPressed: () => themeProvider.toggleTheme(!isDark),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected =
                      _isDisplayingDrawerPage && _selectedDrawerIndex == index;
                  return ListTile(
                    leading: Icon(isSelected ? item.selectedIcon : item.icon),
                    title: Text(item.label),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    onTap: () {
                      setState(() {
                        _selectedDrawerIndex = index;
                        _isDisplayingDrawerPage = true;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context, bool isDark) {
    final horizontalMargin = context.screenWidth < 360 ? 8.0 : 20.0;
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      margin: EdgeInsets.fromLTRB(
        horizontalMargin,
        0,
        horizontalMargin,
        context.responsiveValue(mobile: 24.0, tablet: 32.0),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < double.infinity) {
              return _buildCompactBottomNavigation(isDark);
            }

            return SalomonBottomBar(
              currentIndex: _currentIndex,
              onTap: _onNavigate,
              unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home_rounded),
                  title: const Text('Accueil'),
                  selectedColor: AppColors.primary,
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.book_rounded),
                  title: const Text('Enseignements'),
                  selectedColor: AppColors.primary,
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.calendar_month_sharp),
                  title: const Text('Activités'),
                  selectedColor: AppColors.primary,
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.photo_camera),
                  title: const Text('Galerie'),
                  selectedColor: AppColors.primary,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompactBottomNavigation(bool isDark) {
    const destinations = [
      (icon: Icons.home_rounded, label: 'Accueil'),
      (icon: Icons.book_rounded, label: 'Enseignements'),
      (icon: Icons.calendar_month_sharp, label: 'Activités'),
      (icon: Icons.photo_camera, label: 'Galerie'),
    ];

    return SizedBox(
      height: 68,
      child: Row(
        children: List.generate(destinations.length, (index) {
          final destination = destinations[index];
          final isSelected = index == _currentIndex;
          return Expanded(
            child: Semantics(
              selected: isSelected,
              label: destination.label,
              button: true,
              child: Tooltip(
                message: destination.label,
                child: InkWell(
                  onTap: () => _onNavigate(index),
                  borderRadius: BorderRadius.circular(30),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.14)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              destination.icon,
                              size: 22,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? Colors.white70 : Colors.black54),
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              destination.label,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? Colors.white70 : Colors.black54),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
