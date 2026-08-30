import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/ui_colors.dart';
import '../widgets/app_brand_mark.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Decides between the home dashboard and authentication based on the
/// locally saved session.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: context.screenBg,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppBrandMark(size: 72),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: context.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.data != null) return const HomeScreen();
        return const LoginScreen();
      },
    );
  }
}