import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../models/care_pathway_request.dart';
import '../models/care_pathway_response.dart';
import '../models/patient_profile.dart';
import '../services/auth_service.dart';
import '../services/care_pathway_api_service.dart';
import '../services/profile_service.dart';
import '../theme/app_dimensions.dart';
import '../theme/ui_colors.dart';
import '../widgets/analysis_loading_view.dart';
import '../widgets/app_button.dart';
import '../widgets/app_field.dart';
import '../widgets/app_status_banner.dart';
import '../widgets/page_slide_reveal.dart';
import 'ai_outcome_screen.dart';

class AiInputScreen extends StatefulWidget {
  const AiInputScreen({super.key});

  @override
  State<AiInputScreen> createState() => _AiInputScreenState();
}

class _AiInputScreenState extends State<AiInputScreen> {
  final _api = CarePathwayApiService();
  final _profileService = ProfileService();

  static const int _totalSteps = 3;
  static const List<String> _stepTitles = ['About', 'Symptoms', 'Review'];

  final List<GlobalKey<FormState>> _formKeys = List.generate(
    _totalSteps,
    (_) => GlobalKey<FormState>(),
  );

  final _ageController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _durationController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _medicationsController = TextEditingController();

  int _step = 0;
  String _gender = 'Male';
  String _severity = 'Mild';
  bool _submitting = false;
  String? _analyzeError;

  @override
  void initState() {
    super.initState();
    _loadProfileIntoForm();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _symptomsController.dispose();
    _durationController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileIntoForm() async {
    try {
      final PatientProfile? profile = await _profileService.getProfile();
      if (profile == null || !mounted) return;
      setState(() {
        if (profile.age > 0) _ageController.text = profile.age.toString();
        if (profile.gender.isNotEmpty &&
            const ['Male', 'Female', 'Other'].contains(profile.gender)) {
          _gender = profile.gender;
        }
        _conditionsController.text = profile.existingConditions;
        _medicationsController.text = profile.medications;
      });
    } catch (_) {}
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_formKeys[_step].currentState!.validate()) return;
    setState(() => _step = (_step + 1).clamp(0, _totalSteps - 1));
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) setState(() => _step = _step - 1);
  }

  void _onAnalyzePressed() {
    FocusScope.of(context).unfocus();
    if (!_formKeys[_step].currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _analyzeError = null;
    });

    final navigator = Navigator.of(context);
    // Show the "AI is working" experience while the request is in flight.
    navigator.push(
      MaterialPageRoute(builder: (_) => const AnalysisLoadingScreen()),
    );

    _runAnalysis(navigator);
  }

  Future<void> _runAnalysis(NavigatorState navigator) async {
    try {
      final userId = await AuthService.getCurrentUserId();
      final request = CarePathwayRequest(
        userId: userId,
        age: int.parse(_ageController.text.trim()),
        gender: _gender,
        symptoms: _symptomsController.text.trim(),
        duration: _durationController.text.trim(),
        severity: _severity,
        existingConditions: _conditionsController.text.trim(),
        medications: _medicationsController.text.trim(),
      );

      final CarePathwayResponse response = await _api.analyze(request);
      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (_) => AiOutcomeScreen(response: response),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _analyzeError = friendlyError(e);
      });
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          physics: const BouncingScrollPhysics(),
          child: PageSlideReveal(
            key: ValueKey(_step),
            child: _buildStep(),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: context.inputScreenBg,
      appBar: AppBar(
        title: const Text('Symptom Check'),
        backgroundColor: context.inputScreenBg,
      ),
      body: Column(
        children: [
          _stepIndicator(),
          Expanded(child: body),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _stepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
      child: Column(
        children: [
          Row(
            children: [
              _dot(index: 0),
              _connector(to: 1),
              _dot(index: 1),
              _connector(to: 2),
              _dot(index: 2),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: List.generate(_totalSteps, (i) {
              final active = _step == i;
              return Expanded(
                child: Text(
                  _stepTitles[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? context.primary
                        : context.textMuted,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _dot({required int index}) {
    final done = _step > index;
    final current = _step == index;
    final filled = done || current;

    return SizedBox(
      width: 34,
      height: 34,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? context.primary : Colors.transparent,
          border: Border.all(
            color: filled ? context.primary : context.softBorder,
            width: 2,
          ),
        ),
        child: Center(
          child: done
              ? const Icon(Icons.check_rounded,
                  size: 18, color: Colors.white)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: current ? Colors.white : context.textMuted,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _connector({required int to}) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: _step >= to ? context.primary : context.softBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepAbout();
      case 1:
        return _stepSymptoms();
      default:
        return _stepReview();
    }
  }

  Widget _stepHeader(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: context.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: context.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.textSubtle,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepAbout() {
    return Form(
      key: _formKeys[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepHeader(
            'About you',
            'Help us tailor your care guidance',
            Icons.person_outline_rounded,
          ),
          AppTextField(
            controller: _ageController,
            label: 'Age',
            hint: 'e.g. 34',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            validator: (v) {
              final age = int.tryParse((v ?? '').trim());
              if (age == null || age <= 0 || age > 120) {
                return 'Enter a valid age (1–120)';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          AppDropdownField<String>(
            value: _gender,
            items: const ['Male', 'Female', 'Other'],
            label: 'Gender',
            icon: Icons.wc_rounded,
            onChanged: (v) => setState(() => _gender = v ?? 'Male'),
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _conditionsController,
            label: 'Existing conditions',
            hint: 'e.g. diabetes, asthma (optional)',
            icon: Icons.medical_information_outlined,
            minLines: 1,
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _medicationsController,
            label: 'Medications',
            hint: 'e.g. metformin (optional)',
            icon: Icons.medication_outlined,
            minLines: 1,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _stepSymptoms() {
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepHeader(
            'Describe your symptoms',
            'Be specific so we can guide you better',
            Icons.sick_outlined,
          ),
          AppTextField(
            controller: _symptomsController,
            label: 'Symptoms',
            hint: 'e.g. severe chest pain and shortness of breath',
            icon: Icons.sick_outlined,
            minLines: 4,
            maxLines: 8,
            validator: (v) => (v == null || v.trim().length < 3)
                ? 'Please describe your symptoms'
                : null,
          ),
          const SizedBox(height: 14),
          AppTextField(
            controller: _durationController,
            label: 'Duration',
            hint: 'e.g. 2 days, 30 minutes',
            icon: Icons.timer_outlined,
          ),
          const SizedBox(height: 14),
          AppDropdownField<String>(
            value: _severity,
            items: const ['Mild', 'Moderate', 'Severe'],
            label: 'Severity',
            icon: Icons.speed_rounded,
            onChanged: (v) => setState(() => _severity = v ?? 'Mild'),
          ),
        ],
      ),
    );
  }

  Widget _stepReview() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepHeader(
            'Review your details',
            'Confirm before we analyze',
            Icons.rule_rounded,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: context.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: context.softBorder),
            ),
            child: Column(
              children: [
                _reviewRow(Icons.cake_outlined, 'Age', _ageController.text),
                _reviewRow(Icons.wc_rounded, 'Gender', _gender),
                _reviewRow(Icons.sick_outlined, 'Symptoms', _symptomsController.text, flexValue: true),
                _reviewRow(Icons.timer_outlined, 'Duration', _durationController.text, flexValue: true),
                _reviewRow(Icons.speed_rounded, 'Severity', _severity),
                _reviewRow(
                  Icons.medical_information_outlined,
                  'Conditions',
                  _conditionsController.text,
                  flexValue: true,
                ),
                _reviewRow(
                  Icons.medication_outlined,
                  'Medications',
                  _medicationsController.text,
                  flexValue: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (_analyzeError != null) ...[
            AppStatusBanner(tone: AppStatusTone.danger, message: _analyzeError!),
            const SizedBox(height: 14),
          ],
          AppStatusBanner(
            tone: AppStatusTone.info,
            message:
                'Your analysis is generated on-device guidance and is not a medical diagnosis.',
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _reviewRow(
    IconData icon,
    String label,
    String value, {
    bool flexValue = false,
  }) {
    final display = value.trim().isEmpty ? '—' : value.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: context.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                color: context.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              display,
              textAlign: flexValue ? TextAlign.left : TextAlign.start,
              style: TextStyle(
                color: context.textMain,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    final isLast = _step == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: context.screenBg,
        border: Border(top: BorderSide(color: context.softBorder)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
          child: Row(
            children: [
              if (_step > 0) ...[
                Expanded(
                  child: AppButton(
                    label: 'Back',
                    icon: Icons.arrow_back_rounded,
                    variant: AppButtonVariant.outline,
                    minHeight: 52,
                    onPressed: _submitting ? null : _back,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: _step > 0 ? 2 : 1,
                child: AppButton(
                  label: isLast ? 'Analyze' : 'Continue',
                  icon: isLast
                      ? Icons.psychology_alt_rounded
                      : Icons.arrow_forward_rounded,
                  loading: _submitting,
                  minHeight: 52,
                  onPressed:
                      _submitting ? null : (isLast ? _onAnalyzePressed : _next),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}