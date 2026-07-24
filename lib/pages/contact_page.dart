import 'package:flutter/material.dart';
import 'package:la_bonne_semence_mobile/theme/app_colors.dart';
import 'package:la_bonne_semence_mobile/services/apiService/api_client.dart';
import 'package:la_bonne_semence_mobile/services/apiService/content_service.dart';
import 'package:la_bonne_semence_mobile/services/responsive_utils.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
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
                    Text(
                      'Contactez-nous',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Une question ou une suggestion ? Écrivez-nous.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

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

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Adresse mail',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Veuillez entrer votre email';
                        if (!value.contains('@'))
                          return 'Vevillez entrer un email valide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Subject Field
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: 'Objet de la demande',
                        prefixIcon: const Icon(Icons.subject_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Veuillez entrer un objet'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Message Field
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(bottom: 80.0),
                          child: const Icon(Icons.message_outlined),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Veuillez entrer votre message'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;

                              setState(() => _isLoading = true);
                              try {
                                await ContentService.instance.sendContact(
                                  name: _nameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  subject: _subjectController.text.trim(),
                                  message: _messageController.text.trim(),
                                );

                                if (!mounted) return;
                                _formKey.currentState!.reset();
                                _nameController.clear();
                                _emailController.clear();
                                _subjectController.clear();
                                _messageController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Message envoye avec succes !',
                                    ),
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
                                      'Envoi impossible pour le moment.',
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
                              'Envoyer',
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
