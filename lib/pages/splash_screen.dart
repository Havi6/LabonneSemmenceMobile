import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/pages/register_page.dart';
import 'package:la_bonne_semence_mobile/services/apiService/auth_service.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/widget/home_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final hasValidSession = await AuthService.instance.restoreSession();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            hasValidSession ? const HomeLayout() : const RegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.church_outlined, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              'La Bonne Semence',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
