import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/ui_colors.dart';
import 'app_status_banner.dart';

/// Full-screen "AI is working" experience shown while the analysis request is
/// in flight. Stages cycle to keep the wait feel alive without faking
/// backend progress (the API exposes no progress events).
class AnalysisLoadingScreen extends StatefulWidget {
  const AnalysisLoadingScreen({super.key});

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _stages = [
    'Reviewing your symptoms',
    'Processing health information',
    'Generating care guidance',
    'Finalizing your result',
  ];

  late final AnimationController _pulse;
  Timer? _timer;
  int _stageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(milliseconds: 1900), (_) {
      if (!mounted) return;
      setState(() => _stageIndex = (_stageIndex + 1) % _stages.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor: context.screenBg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            _pulsingMark(),
            const SizedBox(height: 34),
            Text(
              'Analyzing your symptoms',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: context.textMain,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Our AI is carefully reviewing the information you provided',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textSubtle),
            ),
            const SizedBox(height: 34),
            SizedBox(
              width: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  backgroundColor: context.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Text(
                _stages[_stageIndex],
                key: ValueKey(_stageIndex),
                style: TextStyle(
                  color: context.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: AppStatusBanner(
                tone: AppStatusTone.info,
                message:
                    'This provides decision-support guidance only and is not a medical diagnosis.',
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _pulsingMark() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final v = _pulse.value;
        return SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Expanding halo.
              Transform.scale(
                scale: 1.0 + v * 0.22,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.primary.withValues(alpha: 0.16 * (1 - v)),
                  ),
                ),
              ),
              // Inner soft ring.
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.primarySoft,
                  border: Border.all(
                    color: context.primary.withValues(alpha: 0.25),
                  ),
                ),
              ),
              // Pulsing icon.
              Transform.scale(
                scale: 1.0 - v * 0.08,
                child: Icon(
                  Icons.psychology_alt_rounded,
                  size: 58,
                  color: context.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}