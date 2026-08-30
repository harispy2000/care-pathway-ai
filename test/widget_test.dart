import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/screens/splash_screen.dart';

void main() {
  testWidgets('Splash screen shows app name and transitions', (tester) async {
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          onFinish: () => finished = true,
        ),
      ),
    );

    expect(find.text('Care Pathway AI'), findsOneWidget);
    expect(find.text('Your AI-assisted health companion'), findsOneWidget);

    // Run the staggered entrance animation.
    await tester.pump(const Duration(milliseconds: 1600));
    // Allow the post-animation delay to elapse.
    await tester.pump(const Duration(milliseconds: 300));
    // Fade-out phase.
    await tester.pump(const Duration(milliseconds: 350));
    // onFinish should have fired by now.
    await tester.pump();

    expect(finished, isTrue);
  });
}