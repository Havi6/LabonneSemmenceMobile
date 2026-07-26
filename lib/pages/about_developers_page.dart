import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';
import 'package:la_bonne_semence_mobile/widget/reveal_item.dart';

class AboutDevelopersPage extends StatelessWidget {
  const AboutDevelopersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "L'Équipe de Développement",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.pageHorizontalPadding),
        child: Column(
          children: [
            const RevealItem(
              delay: Duration(milliseconds: 200),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.code, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            RevealItem(
              delay: const Duration(milliseconds: 400),
              child: Text(
                "Cette application a été conçue et développée avec soin pour la communauté de la Bonne Semence.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildDevCard(
              context,
              name: "Équipe CABCS",
              role: "Développement Mobile & Backend",
              description: "Passionnés par la technologie et au service de l'évangile.",
              delay: 600,
            ),
            const SizedBox(height: 16),
            _buildTechSection(context, delay: 800),
          ],
        ),
      ),
    );
  }

  Widget _buildDevCard(
    BuildContext context, {
    required String name,
    required String role,
    required String description,
    required int delay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RevealItem(
      delay: Duration(milliseconds: delay),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: isDark ? AppColors.surfaceLight.withValues(alpha: 0.3) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const Divider(height: 32),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechSection(BuildContext context, {required int delay}) {
    return RevealItem(
      delay: Duration(milliseconds: delay),
      child: Column(
        children: [
          const Text(
            "Technologies utilisées",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTechChip("Flutter"),
              const SizedBox(width: 8),
              _buildTechChip("Dart"),
              const SizedBox(width: 8),
              _buildTechChip("Node.js"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      side: const BorderSide(color: AppColors.primary, width: 0.5),
      labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
    );
  }
}
