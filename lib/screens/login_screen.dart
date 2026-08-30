import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../services/auth_service.dart';
import '../theme/app_dimensions.dart';
import '../theme/ui_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_brand_mark.dart';
import '../widgets/app_field.dart';
import '../widgets/app_status_banner.dart';
import '../widgets/auth_shell.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
    return AuthShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Center(child: AppBrandMark(size: 104)),
            const SizedBox(height: 26),
            Text(
              'Welcome back',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: context.textMain,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to your health companion',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSubtle, fontSize: 15),
            ),
            const SizedBox(height: 30),
            if (_error != null) ...[
              AppStatusBanner(tone: AppStatusTone.danger, message: _error!),
              const SizedBox(height: 16),
            ],
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
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your password' : null,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Sign in',
              icon: Icons.arrow_forward_rounded,
              loading: _isLoading,
              onPressed: _isLoading ? null : _login,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New here?',
                  style: TextStyle(color: context.textSubtle),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                  child: const Text('Create an account'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }
}