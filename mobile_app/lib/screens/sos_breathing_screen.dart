import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_dimensions.dart';
import '../theme/ui_colors.dart';
import '../widgets/tilt_3d_card.dart';

/// Calming guided-breathing exercise (box breathing) with a pulsing 3D orb.
/// Includes a quick emergency dial action.
class SosBreathingScreen extends StatefulWidget {
  const SosBreathingScreen({super.key});

  @override
  State<SosBreathingScreen> createState() => _SosBreathingScreenState();
}

enum _Phase { inhale, hold, exhale, rest }

extension _PhaseX on _Phase {
  String get label {
    switch (this) {
      case _Phase.inhale:
        return 'Breathe in';
      case _Phase.hold:
        return 'Hold';
      case _Phase.exhale:
        return 'Breathe out';
      case _Phase.rest:
        return 'Rest';
    }
  }

  Duration get duration {
    switch (this) {
      case _Phase.inhale:
        return const Duration(seconds: 4);
      case _Phase.hold:
        return const Duration(seconds: 4);
      case _Phase.exhale:
        return const Duration(seconds: 4);
      case _Phase.rest:
        return const Duration(seconds: 2);
    }
  }

  _Phase get next {
    switch (this) {
      case _Phase.inhale:
        return _Phase.hold;
      case _Phase.hold:
        return _Phase.exhale;
      case _Phase.exhale:
        return _Phase.rest;
      case _Phase.rest:
        return _Phase.inhale;
    }
  }
}

class _SosBreathingScreenState extends State<SosBreathingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _orb = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  _Phase _phase = _Phase.inhale;
  Timer? _phaseTimer;
  int _cycles = 0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _running = true;
    _advance(_Phase.inhale);
  }

  void _advance(_Phase phase) {
    setState(() => _phase = phase);
    HapticFeedback.selectionClick();

    switch (phase) {
      case _Phase.inhale:
      case _Phase.exhale:
        _orb.duration = phase.duration;
        _orb.animateTo(
          phase == _Phase.inhale ? 1 : 0,
          curve: Curves.easeInOut,
          duration: phase.duration,
        );
      case _Phase.hold:
      case _Phase.rest:
        break;
    }

    _phaseTimer?.cancel();
    _phaseTimer = Timer(phase.duration, () {
      if (!mounted) return;
      var next = _phase.next;
      if (next == _Phase.inhale) {
        _cycles++;
        if (_cycles >= 8) {
          setState(() => _running = false);
          _orb.animateTo(0, duration: const Duration(seconds: 2));
          HapticFeedback.mediumImpact();
          return;
        }
      }
      _advance(next);
    });
  }

  void _restart() {
    _phaseTimer?.cancel();
    _cycles = 0;
    _orb.value = 0;
    _start();
  }

  Future<void> _callEmergency() async {
    final uri = Uri(scheme: 'tel', path: '911');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the dialer')),
      );
    }
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _orb.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.primary;
    final done = !_running && _cycles >= 8;

    return Scaffold(
      backgroundColor: context.screenBg,
      appBar: AppBar(title: const Text('SOS Breathing')),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
                child: AnimatedBuilder(
                  animation: _orb,
                  builder: (context, _) => _Orb3D(
                    progress: _orb.value,
                    color: accent,
                    dark: context.isDarkMode,
                    child: Text(
                      _phase.label,
                      style: TextStyle(
                        color: context.textMain,
                        fontWeight: FontWeight.w700,
                        fontSize: 19,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.all_inclusive_rounded,
                      size: 18, color: context.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    done
                        ? 'Session complete — well done'
                        : 'Cycle ${_cycles + 1} of 8',
                    style: TextStyle(
                      color: done ? accent : context.textSubtle,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Tilt3DCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates_outlined,
                            color: accent, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: TextStyle(
                            color: context.textMain,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Box breathing: inhale 4s, hold 4s, exhale 4s, rest 2s. '
                      'It slows your heart rate and calms the nervous system — '
                      'helpful for anxiety, panic or stress episodes.',
                      style: TextStyle(
                        color: context.textSubtle,
                        height: 1.5,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (done)
                FilledButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Start another session'),
                ),
              if (!done) ...[
                Text(
                  'Follow the orb: it grows as you inhale and shrinks as you exhale.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.textMuted, fontSize: 12.5),
                ),
              ],
              const SizedBox(height: 18),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(
                    color: AppColors.danger.withValues(alpha: 0.4),
                  ),
                  minimumSize: const Size(0, 52),
                ),
                onPressed: _callEmergency,
                icon: const Icon(Icons.emergency_rounded),
                label: const Text('Call emergency services'),
              ),
              const SizedBox(height: 6),
              Text(
                'If this is a medical emergency, call your local emergency number immediately.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textMuted, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Layered, glowing orb that expands/contracts with [progress] (0..1).
class _Orb3D extends StatelessWidget {
  final double progress;
  final Color color;
  final bool dark;
  final Widget? child;

  const _Orb3D({
    required this.progress,
    required this.color,
    required this.dark,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = 150.0 + progress * 80;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer halo.
        Container(
          width: size + 70,
          height: size + 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.10 + progress * 0.10),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        // Mid glow.
        Container(
          width: size + 26,
          height: size + 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.14),
          ),
        ),
        // Core with 3D gradient.
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              radius: 1.1,
              colors: [
                Color.lerp(color, Colors.white, 0.55)!,
                color,
                Color.lerp(color, dark ? Colors.black : AppColors.primaryDark,
                    0.35)!,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 34 + progress * 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ],
    );
  }
}
