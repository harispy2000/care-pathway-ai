import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/ui_colors.dart';
import '../widgets/app_brand_mark.dart';

/// Premium entrance experience: scale-in brand mark, staggered text reveal,
/// then a clean dissolve into the auth flow. Short enough not to delay startup.
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _markScale;
  late final Animation<double> _markFade;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _progressFade;

  bool _fadingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    final markCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
    );
    _markScale = Tween(begin: 0.55, end: 1.0).animate(markCurve);
    _markFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _titleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.6, curve: Curves.easeOut),
      ),
    );
    _subtitleFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.7, curve: Curves.easeOut),
      ),
    );
    _progressFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
      ),
    );

    _controller.forward().whenComplete(() async {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() => _fadingOut = true);
      await Future.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
      widget.onFinish();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.screenBg,
      body: AnimatedOpacity(
        opacity: _fadingOut ? 0.0 : 1.0,
        duration: AppDimensions.slow,
        curve: Curves.easeInOut,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _backgroundDecor(),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _markFade,
                        child: ScaleTransition(
                          scale: _markScale,
                          child: child,
                        ),
                      );
                    },
                    child: const AppBrandMark(size: 116),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _titleFade,
                    child: Text(
                      'Care Pathway AI',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: context.textMain,
                            letterSpacing: 0.3,
                          ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: FadeTransition(
                      opacity: _subtitleFade,
                      child: Text(
                        'Your AI-assisted health companion',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.textSubtle, fontSize: 15),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _progressFade,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: SizedBox(
                        width: 140,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor:
                                context.primary.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backgroundDecor() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.primarySoft.withValues(alpha: 0.55),
            context.screenBg,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -70,
            child: _floatCircle(
              size: 230,
              color: context.primary.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _floatCircle(
              size: 260,
              color: AppColors.secondary.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  Widget _floatCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}