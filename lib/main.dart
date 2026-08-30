import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/splash_screen.dart';
import 'services/firebase_notification_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ThemeController.instance.loadTheme();

  final shouldInitializeFirebase =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  if (shouldInitializeFirebase && DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseNotificationService.instance.init();
  }

  runApp(const CarePathwayApp());
}

class CarePathwayApp extends StatefulWidget {
  const CarePathwayApp({super.key});

  @override
  State<CarePathwayApp> createState() => _CarePathwayAppState();
}

class _CarePathwayAppState extends State<CarePathwayApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Care Pathway AI",
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.instance.themeMode,
          home: _showSplash
              ? SplashScreen(
                  onFinish: () => setState(() => _showSplash = false),
                )
              : const AuthGate(),
        );
      },
    );
  }
}
