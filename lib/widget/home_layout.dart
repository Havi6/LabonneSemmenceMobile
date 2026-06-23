import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/pages/calendar_page.dart';
import 'package:la_bonne_semence_mobile/pages/galery_page.dart';
import 'package:la_bonne_semence_mobile/pages/home_page.dart';
import 'package:la_bonne_semence_mobile/pages/sermons_page.dart';
import 'package:la_bonne_semence_mobile/pages/donnation_page.dart';
import 'package:la_bonne_semence_mobile/pages/contact_page.dart';
import 'package:la_bonne_semence_mobile/pages/about_us_page.dart';
import 'package:la_bonne_semence_mobile/pages/account_page.dart';
import 'package:la_bonne_semence_mobile/pages/setting_page.dart';
import 'package:la_bonne_semence_mobile/pages/admin_page.dart';
import 'package:la_bonne_semence_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../theme/app_colors.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int? _selectedRailIndex;
  bool _isRailExtended = false;
  bool _showRail = true;
  bool _isDisplayingRailPage = false;

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
      _isDisplayingRailPage = false;
      _selectedRailIndex = null;
    });
  }

  late final List<Widget> _bottomPages;

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

  final List<Widget> _railPages = [
    const DonnationPage(),
    const ContactPage(),
    const AboutUsPage(),
    const Profile(), 
    const SettingPage(),
    const AdminPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    Widget currentBody = _isDisplayingRailPage 
        ? _railPages[_selectedRailIndex ?? 0]
        : _bottomPages[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.church_outlined,
              color: AppColors.primary,
            ),
            SizedBox(width: 12),
            Text(
              "La Bonne Semence",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Navigation Rail
          if (_showRail) ...[
            NavigationRail(
              extended: _isRailExtended,
              selectedIndex: _selectedRailIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedRailIndex = index;
                  _isDisplayingRailPage = true;
                });
              },
              labelType: NavigationRailLabelType.none,
              backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
              unselectedIconTheme: IconThemeData(color: isDark ? Colors.white70 : Colors.black54),
              leading: Column(
                children: [
                  const SizedBox(height: 8),
                  IconButton(
                    icon: Icon(_isRailExtended ? Icons.menu_open : Icons.menu),
                    onPressed: () {
                      setState(() {
                        _isRailExtended = !_isRailExtended;
                      });
                    },
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                    onPressed: () => themeProvider.toggleTheme(!isDark),
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.volunteer_activism_outlined),
                  selectedIcon: Icon(Icons.volunteer_activism),
                  label: Text('Dons'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.contact_support_outlined),
                  selectedIcon: Icon(Icons.contact_support),
                  label: Text('Contact'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info_outline),
                  selectedIcon: Icon(Icons.info),
                  label: Text('À propos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_circle_outlined),
                  selectedIcon: Icon(Icons.account_circle),
                  label: Text('Compte'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Paramètres'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.admin_panel_settings_outlined),
                  selectedIcon: Icon(Icons.admin_panel_settings),
                  label: Text('Admin'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
          ],
          // Contenu principal avec animation de transition
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_isDisplayingRailPage ? "rail_$_selectedRailIndex" : "bottom_$_currentIndex"),
                child: currentBody,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: AppColors.primary,
        onPressed: () {
          setState(() {
            _showRail = !_showRail;
          });
        },
        child: Icon(
          _showRail ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: SalomonBottomBar(
            currentIndex: _currentIndex,
            onTap: (i) {
              setState(() {
                _currentIndex = i;
                _isDisplayingRailPage = false;
                _selectedRailIndex = null;
              });
            },
            unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.home_rounded),
                title: const Text("Accueil"),
                selectedColor: AppColors.primary,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.book_rounded),
                title: const Text("Enseignements"),
                selectedColor: AppColors.primary,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.calendar_month_sharp),
                title: const Text("Activités"),
                selectedColor: AppColors.primary,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.photo_camera),
                title: const Text("Galerie"),
                selectedColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
