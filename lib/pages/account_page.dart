import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/pages/login_page.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/auth_service.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
    final email = _readUser('email') ?? 'Non renseigné';
    final rawDate = _readUser('createdAt') ?? _readUser('created_at');
    final createdAt = _formatDate(rawDate);

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
                    child: CircleAvatar(
                      radius: context.responsiveValue(mobile: 45.0, tablet: 65.0),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        size: context.responsiveValue(mobile: 50.0, tablet: 75.0),
                        color: AppColors.primary,
                      ),
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
                    _buildSectionHeader(
                      "Identité",
                      action: TextButton.icon(
                        onPressed: () => _showEditProfileDialog(context),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text("Modifier"),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
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
                      onTap: () => _showChangePasswordDialog(context),
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

  Widget _buildSectionHeader(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (action != null) action,
        ],
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
    VoidCallback? onTap,
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
      onTap: onTap ?? () {},
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isChanging = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Modifier le mot de passe"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Ancien mot de passe",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Champ requis" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Nouveau mot de passe",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.length < 6
                          ? "Minimum 6 caractères"
                          : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isChanging ? null : () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            FilledButton(
              onPressed: isChanging
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() => isChanging = true);
                        try {
                          await AuthService.instance.changePassword(
                            currentPassword: oldPasswordController.text,
                            newPassword: newPasswordController.text,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Mot de passe modifié avec succès"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } on ApiException catch (e) {
                          if (context.mounted) {
                            setDialogState(() => isChanging = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setDialogState(() => isChanging = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Une erreur est survenue"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: isChanging
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Modifier"),
            ),
          ],
        ),
      ),
    );

    // Attendre la fin de l'animation de fermeture avant de libérer les ressources
    Future.delayed(const Duration(milliseconds: 300), () {
      oldPasswordController.dispose();
      newPasswordController.dispose();
    });
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final currentName =
        _readUser('name') ?? _readUser('username') ?? '';
    final nameController = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();
    bool isUpdating = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Modifier mon profil"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nom / Pseudonyme",
                    border: OutlineInputBorder(),
                    hintText: "Entrez votre nom",
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? "Champ requis" : null,
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                const Text(
                  "L'e-mail ne peut pas être modifié pour des raisons de sécurité.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            FilledButton(
              onPressed: isUpdating
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        setDialogState(() => isUpdating = true);
                        try {
                          final userId = _readUser('id') ?? _readUser('_id');
                          if (userId == null) throw Exception("ID utilisateur introuvable");
                          
                          await AuthService.instance.updateUsername(
                            id: userId,
                            username: nameController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            _loadProfile(); // Rafraîchir les infos
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Profil mis à jour"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } on ApiException catch (e) {
                          if (context.mounted) {
                            setDialogState(() => isUpdating = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            setDialogState(() => isUpdating = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Erreur lors de la mise à jour"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );

    // Attendre la fin de l'animation de fermeture
    Future.delayed(const Duration(milliseconds: 300), () => nameController.dispose());
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

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty || rawDate == 'null') {
      return 'Non renseigné';
    }
    try {
      final dateTime = DateTime.parse(rawDate);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (_) {
      return rawDate;
    }
  }
}
