import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/care_pathway_response.dart';
import '../models/patient_profile.dart';
import '../services/notification_scheduler.dart';
import '../services/profile_service.dart';
import '../theme/app_risk.dart';
import '../theme/ui_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/echo_tap.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/page_slide_reveal.dart';
import '../widgets/risk_gauge.dart';
import '../widgets/tilt_3d_card.dart';
import 'ai_input_screen.dart';

class AiOutcomeScreen extends StatelessWidget {
  final CarePathwayResponse response;

  const AiOutcomeScreen({super.key, required this.response});

  String _summaryText(BuildContext context) {
    final buffer = StringBuffer()
      ..writeln('Care Pathway AI — Analysis Summary')
      ..writeln('Triage: ${response.triageLevel} (risk ${response.riskScore}/100)')
      ..writeln('Possible condition: ${response.possibleCondition}')
      ..writeln('Recommended action: ${response.recommendedAction}')
      ..writeln('Safety advice: ${response.safetyAdvice}');
    if (response.redFlags.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Red flags:')
        ..writeAll(response.redFlags.map((e) => '  • $e\n'));
    }
    if (response.careSteps.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Care steps:')
        ..writeAll(response.careSteps.map((e) => '  • $e\n'));
    }
    buffer
      ..writeln()
      ..writeln('AI-assisted guidance only — not a medical diagnosis.');
    return buffer.toString();
  }

  Future<void> _share(BuildContext context) async {
    await Share.share(
      _summaryText(context),
      subject: 'Care Pathway AI result',
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _summaryText(context)));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final risk = appRiskLevelFor(response.triageLevel, response.riskScore);
    final accent = risk.color(context);

    return Scaffold(
      backgroundColor: context.screenBg,
      appBar: AppBar(
        title: const Text('Analysis Result'),
        actions: [
          IconButton(
            tooltip: 'Copy summary',
            icon: const Icon(Icons.copy_rounded),
            onPressed: () => _copy(context),
          ),
          IconButton(
            tooltip: 'Share summary',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _share(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        physics: const BouncingScrollPhysics(),
        children: [
          PageSlideReveal(
            child: RiskGauge(
              triageLevel: response.triageLevel,
              riskScore: response.riskScore,
              caption: response.recommendedAction,
            ),
          ),
          const SizedBox(height: 14),
          const _EmergencyContactSection(),
          const SizedBox(height: 18),
          _section(
            context,
            title: 'Possible Condition',
            items: [response.possibleCondition],
            icon: Icons.health_and_safety_outlined,
            color: accent,
          ),
          _section(
            context,
            title: 'Safety Advice',
            items: [response.safetyAdvice],
            icon: Icons.security_outlined,
          ),
          _section(
            context,
            title: 'Red Flags',
            items: response.redFlags,
            icon: Icons.warning_amber_rounded,
            color: AppColors.danger,
          ),
          PageSlideReveal(
            duration: const Duration(milliseconds: 420),
            child: _CareStepsCard(
              steps: response.careSteps,
              analysisKey: '${response.triageLevel}-${response.riskScore}-${response.careSteps.length}',
            ),
          ),
          _section(
            context,
            title: 'Matched Factors',
            items: response.matchedFactors,
            icon: Icons.fact_check_outlined,
          ),
          const SizedBox(height: 4),
          const _AppStatusBannerInfo(),
          const SizedBox(height: 22),
          AppButton(
            label: 'Start new symptom check',
            icon: Icons.psychology_alt_rounded,
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AiInputScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required List<String> items,
    required IconData icon,
    Color? color,
  }) {
    if (items.isEmpty || items.every((x) => x.trim().isEmpty)) {
      return const SizedBox.shrink();
    }
    final c = color ?? AppColors.primary;

    return PageSlideReveal(
      duration: const Duration(milliseconds: 380),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Tilt3DCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PulseAvatar3D(icon: icon, color: c, size: 34),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: context.textMain,
                      ),
                    ),
                  ),
                ],
              ),
              if (title == 'Care Steps' || title == 'Matched Factors') ...[
                const SizedBox(height: 6),
                const Divider(),
              ],
              const SizedBox(height: 8),
              ...items.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(top: 7),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e,
                          style: TextStyle(
                            color: context.textSubtle,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive care-step checklist. Tapping a step marks it done with a
/// satisfying animation; "Remind me" schedules tomorrow's follow-ups.
class _CareStepsCard extends StatefulWidget {
  final List<String> steps;
  final String analysisKey;

  const _CareStepsCard({
    required this.steps,
    required this.analysisKey,
  });

  @override
  State<_CareStepsCard> createState() => _CareStepsCardState();
}

class _CareStepsCardState extends State<_CareStepsCard> {
  final Set<int> _done = {};

  bool get _allDone =>
      widget.steps.isNotEmpty && _done.length == widget.steps.length;

  Future<void> _scheduleReminders() async {
    final ok = await NotificationScheduler.instance.requestPermissions();
    await NotificationScheduler.instance.scheduleCareStepFollowUps(
      analysisId: widget.analysisKey.hashCode,
      steps: widget.steps,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Follow-up reminders scheduled for tomorrow'
              : 'Reminders may need notification permission',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Tilt3DCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const PulseAvatar3D(
                  icon: Icons.checklist_rounded,
                  color: AppColors.success,
                  size: 34,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Care Steps',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: context.textMain,
                    ),
                  ),
                ),
                Text(
                  '${_done.length}/${widget.steps.length}',
                  style: TextStyle(
                    color: context.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _done.length / widget.steps.length),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: context.primary.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(AppColors.success),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(widget.steps.length, (i) {
              final done = _done.contains(i);
              return _CheckableStep(
                index: i,
                label: widget.steps[i],
                done: done,
                onToggle: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (done) {
                      _done.remove(i);
                    } else {
                      _done.add(i);
                    }
                  });
                },
              );
            }),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _scheduleReminders,
                    icon: const Icon(Icons.alarm_add_rounded, size: 18),
                    label: const Text(
                      'Remind me tomorrow',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (_allDone) ...[
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckableStep extends StatelessWidget {
  final int index;
  final String label;
  final bool done;
  final VoidCallback onToggle;

  const _CheckableStep({
    required this.index,
    required this.label,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.success : context.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: EchoTap(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: done
                ? AppColors.success.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? color : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 15, color: Colors.white)
                    : Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: context.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: done ? context.textMuted : context.textMain,
                    decoration:
                        done ? TextDecoration.lineThrough : TextDecoration.none,
                    height: 1.4,
                    fontSize: 14,
                  ),
                  child: Text(label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppStatusBannerInfo extends StatelessWidget {
  const _AppStatusBannerInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.info,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'This is AI-assisted guidance only and not a medical diagnosis. '
              'Always consult a healthcare professional.',
              style: TextStyle(
                color: context.textSubtle,
                height: 1.4,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContactSection extends StatefulWidget {
  const _EmergencyContactSection();

  @override
  State<_EmergencyContactSection> createState() =>
      _EmergencyContactSectionState();
}

class _EmergencyContactSectionState extends State<_EmergencyContactSection> {
  final _profileService = ProfileService();
  PatientProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await _profileService.getProfile();
      if (mounted) setState(() => _profile = p);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return EmergencyContactCard(
      contactName: _profile?.emergencyContactName,
      contactNumber: _profile?.emergencyContactNumber,
    );
  }
}
