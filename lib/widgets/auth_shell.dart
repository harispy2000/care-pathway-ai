import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/ui_colors.dart';

/// Shared structure for authentication screens: decorative background,
/// safe area, centered content capped to a comfortable width.
class AuthShell extends StatelessWidget {
  final Widget child;
  final bool scrollable;

  const AuthShell({
    super.key,
    required this.child,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final body = ChildContent(body: child);

    return Scaffold(
      backgroundColor: context.screenBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _backgroundDecor(context),
          SafeArea(
            child: scrollable
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.pageGutter,
                      vertical: 24,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: body,
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.pageGutter,
                      vertical: 24,
                    ),
                    child: body,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundDecor(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.primarySoft.withValues(alpha: 0.45),
              context.screenBg,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primary.withValues(alpha: 0.06),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChildContent extends StatelessWidget {
  final Widget body;

  const ChildContent({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.maxContentWidth - 32,
        ),
        child: body,
      ),
    );
  }
}