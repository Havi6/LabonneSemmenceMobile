import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Politique de Confidentialité",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("Dernière mise à jour : 26 Juillet 2026"),
            const SizedBox(height: 20),
            _buildSectionTitle("1. Introduction"),
            _buildSectionContent(
              "Bienvenue sur l'application 'La Bonne Semence'. Nous accordons une grande importance à la protection de vos données personnelles et au respect de votre vie privée. Cette politique de confidentialité vous informe sur la manière dont nous collectons, utilisons et protégeons vos informations.",
            ),
            _buildSectionTitle("2. Collecte des données"),
            _buildSectionContent(
              "Nous collectons les informations suivantes :\n\n"
              "• Informations fournies volontairement : Nom, adresse e-mail et contenu des messages envoyés via notre formulaire de contact.\n"
              "• Données d'utilisation : Informations sur la manière dont vous interagissez avec l'application (pages consultées, temps passé) afin d'améliorer votre expérience utilisateur.",
            ),
            _buildSectionTitle("3. Utilisation des données"),
            _buildSectionContent(
              "Vos données sont utilisées pour :\n\n"
              "• Répondre à vos demandes de contact.\n"
              "• Assurer le bon fonctionnement de l'application.\n"
              "• Analyser l'utilisation de l'application pour en améliorer le contenu et les fonctionnalités.",
            ),
            _buildSectionTitle("4. Protection et Sécurité"),
            _buildSectionContent(
              "Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles appropriées pour protéger vos données contre tout accès non autorisé, altération ou destruction. L'accès à vos données personnelles est strictement limité aux administrateurs autorisés.",
            ),
            _buildSectionTitle("5. Partage des données"),
            _buildSectionContent(
              "Nous ne vendons, ne louons, ni ne partageons vos données personnelles avec des tiers à des fins commerciales. Vos informations ne sont divulguées que si la loi l'exige ou pour protéger nos droits.",
            ),
            _buildSectionTitle("6. Vos droits"),
            _buildSectionContent(
              "Conformément aux réglementations en vigueur, vous disposez d'un droit d'accès, de rectification et de suppression de vos données personnelles. Vous pouvez exercer ces droits à tout moment en nous contactant via le formulaire de l'application.",
            ),
            _buildSectionTitle("7. Modifications"),
            _buildSectionContent(
              "Nous nous réservons le droit de modifier cette politique de confidentialité à tout moment. Toute modification sera publiée sur cette page avec une date de mise à jour révisée.",
            ),
            _buildSectionTitle("8. Contact"),
            _buildSectionContent(
              "Pour toute question concernant cette politique de confidentialité, veuillez nous contacter à l'adresse suivante : contact@labonnesemence.org",
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontStyle: FontStyle.italic,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
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

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(
        fontSize: 15,
        height: 1.5,
      ),
    );
  }
}
