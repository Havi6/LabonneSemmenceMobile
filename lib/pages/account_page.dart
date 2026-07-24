import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/pages/login_page.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/auth_service.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await AuthService.instance.me();
      if (!mounted) return;
      setState(() {
        _user = _unwrapUser(user);
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoggingOut = true);
    try {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final name = _readUser('name') ?? _readUser('username') ?? 'Utilisateur';
    final email = _readUser('email') ?? 'Non renseigne';
    final createdAt =
        _readUser('createdAt') ?? _readUser('created_at') ?? 'Non renseigne';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.pageHorizontalPadding,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.formMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Mon Profil",
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: context.responsiveValue(
                        mobile: 24.0,
                        tablet: 32.0,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  // Header avec photo de profil
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: context.responsiveValue(
                                  mobile: 40.0,
                                  tablet: 60.0,
                                ),
                                backgroundColor: Colors.transparent,
                                child: Icon(
                                  Icons.person,
                                  size: context.responsiveValue(
                                    mobile: 60.0,
                                    tablet: 90.0,
                                  ),
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  else ...[
                    _buildSectionHeader("Identité"),
                    _buildProfileCard([
                      _buildListTile(
                        "Nom du profil",
                        name,
                        Icons.person_outline,
                      ),
                      _buildListTile(
                        "Date de création du compte",
                        createdAt,
                        Icons.lock_clock_outlined,
                      ),
                      _buildListTile("Email", email, Icons.email_outlined),
                    ]),
                  ],

                  const SizedBox(height: 24),
                  _buildSectionHeader("Préférences"),
                  _buildProfileCard([
                    SwitchListTile(
                      title: const Text("Mode sombre"),
                      secondary: const Icon(
                        Icons.dark_mode_outlined,
                        color: AppColors.primary,
                      ),
                      value: themeProvider.isDarkMode,
                      activeColor: AppColors.primary,
                      onChanged: (value) => themeProvider.toggleTheme(value),
                    ),
                  ]),

                  const SizedBox(height: 24),
                  _buildSectionHeader("Sécurité"),
                  _buildProfileCard([
                    _buildListTile(
                      "Modifier le mot de passe",
                      null,
                      Icons.lock_outline,
                    ),
                    _buildListTile(
                      "Supprimer le compte",
                      null,
                      Icons.delete_outline,
                      isDestructive: true,
                    ),
                  ]),

                  const SizedBox(height: 32),
                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: _isLoggingOut ? null : _logout,
                    icon: _isLoggingOut
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.logout),
                    label: const Text("Se déconnecter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: context.bottomNavigationClearance),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildProfileCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(
    String title,
    String? subtitle,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {},
    );
  }

  Map<String, dynamic>? _unwrapUser(Map<String, dynamic>? data) {
    if (data == null) return null;

    final nestedUser = data['user'] ?? data['data'];
    if (nestedUser is Map<String, dynamic>) {
      return nestedUser;
    }

    return data;
  }

  String? _readUser(String key) {
    final value = _user?[key];
    return value?.toString();
  }
}
