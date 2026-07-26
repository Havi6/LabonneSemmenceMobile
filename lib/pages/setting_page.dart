import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/pages/privacy_policy_page.dart';
import 'package:la_bonne_semence_mobile/pages/about_developers_page.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/widget/reveal_item.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Paramètres",
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RevealItem(
              delay: const Duration(milliseconds: 100),
              child: _buildSettingCard(
                context,
                icon: Icons.bug_report_outlined,
                title: "Rapport de bugs",
                subtitle: "Signaler un problème technique",
                onTap: () {},
              ),
            ),
            const SizedBox(height: 16),
            RevealItem(
              delay: const Duration(milliseconds: 200),
              child: _buildSettingCard(
                context,
                icon: Icons.privacy_tip_outlined,
                title: "Politique de confidentialité",
                subtitle: "Consulter nos engagements",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            RevealItem(
              delay: const Duration(milliseconds: 300),
              child: _buildSettingCard(
                context,
                icon: Icons.code_outlined,
                title: "À propos des développeurs",
                subtitle: "Découvrir l'équipe CABCS",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutDevelopersPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: isDark ? AppColors.surfaceLight.withOpacity(0.5) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
