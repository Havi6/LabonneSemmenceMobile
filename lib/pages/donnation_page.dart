import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/content_service.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';

class DonnationPage extends StatefulWidget {
  const DonnationPage({super.key});

  @override
  State<DonnationPage> createState() => _DonnationPageState();
}

class _DonnationPageState extends State<DonnationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  double _amount = 10.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.pageHorizontalPadding,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.formMaxWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: context.responsiveValue(
                        mobile: 60.0,
                        tablet: 100.0,
                      ),
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Faire un don',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: context.responsiveValue(
                          mobile: 24.0,
                          tablet: 32.0,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Soutenez notre mission par votre générosité.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.percentHeight(4)),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nom complet',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Veuillez entrer votre nom'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Veuillez entrer votre numéro'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    // Amount Section
                    Text(
                      'Montant du don : ${_amount.toInt()} \$',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Slider(
                      value: _amount,
                      min: 5.0,
                      max: 500.0,
                      divisions: 99,
                      label: '${_amount.toInt()} \$',
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.primary.withOpacity(0.2),
                      onChanged: (double value) {
                        setState(() {
                          _amount = value;
                        });
                      },
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('5 \$'), Text('500 \$')],
                    ),
                    const SizedBox(height: 48),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              setState(() => _isLoading = true);
                              try {
                                await ContentService.instance.createDonation(
                                  name: _nameController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                  amount: _amount.toInt(),
                                );

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Merci pour votre don de ${_amount.toInt()} \$ !',
                                    ),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              } on ApiException catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message)),
                                );
                              } catch (_) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Don impossible pour le moment.',
                                    ),
                                  ),
                                );
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Confirmer le don',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
  }
}
