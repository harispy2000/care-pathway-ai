import 'package:flutter/material.dart';

import '../models/care_pathway_response.dart';
import '../models/patient_profile.dart';
import '../services/profile_service.dart';
import '../theme/app_risk.dart';
import '../theme/ui_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/page_slide_reveal.dart';
import '../widgets/risk_gauge.dart';
import 'ai_input_screen.dart';

class AiOutcomeScreen extends StatelessWidget {
  final CarePathwayResponse response;

  const AiOutcomeScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final risk = appRiskLevelFor(response.triageLevel, response.riskScore);

    return Scaffold(
      backgroundColor: context.screenBg,
      appBar: AppBar(title: const Text('Analysis Result')),
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
          PageSlideReveal(
            duration: const Duration(milliseconds: 340),
            child: _section(
              context,
              title: 'Possible Condition',
              items: [response.possibleCondition],
              icon: Icons.health_and_safety_outlined,
              color: risk.color(context),
            ),
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
          _section(
            context,
            title: 'Care Steps',
            items: response.careSteps,
            icon: Icons.check_circle_outline_rounded,
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

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: c, size: 20),
              ),
              const SizedBox(width: 12),
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
              child: Text(
                '• $e',
                style: TextStyle(color: context.textSubtle, height: 1.4),
              ),
            ),
          ),
        ],
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