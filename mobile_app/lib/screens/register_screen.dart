import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../services/auth_service.dart';
import '../theme/ui_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_field.dart';
import '../widgets/app_status_banner.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await AuthService.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.screenBg,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Join Care Pathway AI',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: context.textMain,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create your account to start symptom checks',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.textSubtle),
                    ),
                    const SizedBox(height: 22),
                    if (_error != null) ...[
                      AppStatusBanner(tone: AppStatusTone.danger, message: _error!),
                      const SizedBox(height: 14),
                    ],
                    AppTextField(
                      controller: _nameController,
                      label: 'Full name',
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter your full name' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter a valid email address'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    AppPasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    AppPasswordField(
                      controller: _confirmController,
                      label: 'Confirm password',
                      validator: (v) => (v != _passwordController.text)
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Create Account',
                      icon: Icons.person_add_alt_1_rounded,
                      loading: _isLoading,
                      onPressed: _isLoading ? null : _register,
                    ),
                    const SizedBox(height: 16),
                    AppStatusBanner(
                      tone: AppStatusTone.info,
                      message:
                          'Care Pathway AI provides decision-support guidance only and does not replace professional medical care.',
                    ),
                    const SizedBox(height: 8),
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