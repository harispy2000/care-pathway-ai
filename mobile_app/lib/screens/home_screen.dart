import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/date_format.dart';
import '../core/motion.dart';
import '../models/api_analysis_history_item.dart';
import '../models/medication.dart';
import '../models/patient_profile.dart';
import '../services/analysis_history_api_service.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_risk.dart';
import '../theme/theme_controller.dart';
import '../theme/ui_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_status_banner.dart';
import '../widgets/echo_tap.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/first_aid_carousel.dart';
import '../widgets/tilt_3d_card.dart';
import 'ai_input_screen.dart';
import 'ai_outcome_screen.dart';
import 'analysis_history_screen.dart';
import 'health_insights_screen.dart';
import 'login_screen.dart';
import 'medications_screen.dart';
import 'profile_screen.dart';
import 'sos_breathing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _historyService = AnalysisHistoryApiService();
  final _profileService = ProfileService();
  final _medStore = MedicationStore.instance;

  String _name = '';
  PatientProfile? _profile;
  late Future<List<ApiAnalysisHistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _historyService.getHistory();
    _loadUser();
    _loadProfile();
    _medStore.load();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() => _name = user?.fullName ?? '');
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getProfile();
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      // Profile may not exist yet; the UI shows a prompt to add one.
    }
  }

  Future<void> _refreshHistory() async {
    final future = _historyService.getHistory();
    setState(() => _historyFuture = future);
    await future;
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _openHistoryItem(ApiAnalysisHistoryItem item) async {
    try {
      final response = await _historyService.getHistoryById(item.id);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AiOutcomeScreen(response: response)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open that analysis.')),
      );
    }
  }

  void _openSettings() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _SettingsSheet(),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final hasEmergencyContact =
        (_profile?.emergencyContactNumber.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: context.screenBg,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.maxContentWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    _greetingBlock(),
                    const SizedBox(height: 20),
                    _heroCta(),
                    const SizedBox(height: 16),
                    _quickActions(),
                    const SizedBox(height: 26),
                    _nextDosePreview(),
                    const SizedBox(height: 26),
                    AppSectionHeader(
                      title: 'Recent analysis',
                      subtitle: 'Your latest symptom check',
                      icon: Icons.history_rounded,
                      trailing: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnalysisHistoryScreen(),
                          ),
                        ),
                        child: const Text('View all'),
                      ),
                    ),
                    _recentAnalysis(),
                    const SizedBox(height: 22),
                    const AppSectionHeader(
                      title: 'First aid guide',
                      subtitle: 'Tap a card for step-by-step help',
                      icon: Icons.local_hospital_outlined,
                    ),
                    const SizedBox(height: 6),
                    const FirstAidCarousel(),
                    const SizedBox(height: 22),
                    hasEmergencyContact
                        ? EmergencyContactCard(
                            contactName: _profile?.emergencyContactName,
                            contactNumber: _profile?.emergencyContactNumber,
                          )
                        : _emergencyPrompt(),
                    const SizedBox(height: 6),
                    const AppStatusBanner(
                      tone: AppStatusTone.info,
                      message:
                          'This app provides decision-support guidance only and does not replace a doctor or emergency services.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: const Icon(
            Icons.health_and_safety_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Care Pathway AI',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.textMain,
                    ),
              ),
              Text(
                'Your health companion',
                style: TextStyle(color: context.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: _openSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
        IconButton(
          tooltip: 'Log out',
          onPressed: _logout,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }

  Widget _greetingBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(),
          style: TextStyle(color: context.textSubtle, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          _name.isEmpty ? 'Welcome' : 'Hi, $_name',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: context.textMain,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Describe your symptoms and get AI-assisted care guidance.',
          style: TextStyle(color: context.textMuted, fontSize: 13.5),
        ),
      ],
    );
  }

  /// 3D hero with gyroscope parallax: floating orbs + glow accent the CTA.
  Widget _heroCta() {
    return EchoTap(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AiInputScreen()),
      ),
      semanticLabel: 'Start a symptom check',
      child: Tilt3DCard(
        maxTilt: 0.14,
        showSheen: true,
        padding: EdgeInsets.zero,
        background: Colors.transparent,
        border: Border.all(color: Colors.transparent),
        shadows: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        child: Container(
          height: 172,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Stack(
            children: [
              // Parallax decorative layers.
              ParallaxLayer(
                depth: 18,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Transform.translate(
                    offset: const Offset(34, -34),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ),
              ),
              ParallaxLayer(
                depth: 10,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Transform.translate(
                    offset: const Offset(6, 50),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                            child: const Icon(
                              Icons.psychology_alt_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Start Symptom Check',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'AI-assisted care pathway analysis',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActions() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.medication_rounded,
                color: AppColors.secondary,
                title: 'Medications',
                subtitle: 'Reminders',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MedicationsScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.insights_rounded,
                color: AppColors.tertiary,
                title: 'Insights',
                subtitle: 'Health trends',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HealthInsightsScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.spa_rounded,
                color: AppColors.success,
                title: 'SOS Breathing',
                subtitle: 'Calm down fast',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SosBreathingScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.person_rounded,
                color: AppColors.warning,
                title: 'Profile',
                subtitle: 'Conditions & contacts',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _nextDosePreview() {
    return AnimatedBuilder(
      animation: _medStore,
      builder: (context, _) {
        final next = _medStore.nextDose();
        if (next == null) return const SizedBox.shrink();

        final hours = next.minutes ~/ 60;
        final minutes = next.minutes % 60;
        final meds = _medStore.activeDoseCount;

        return Tilt3DCard(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MedicationsScreen()),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const PulseAvatar3D(
                icon: Icons.alarm_rounded,
                color: AppColors.secondary,
                size: 38,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next: ${next.med.name} in ${hours}h ${minutes.toString().padLeft(2, '0')}m',
                      style: TextStyle(
                        color: context.textMain,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$meds reminder${meds == 1 ? '' : 's'} active today — tap to manage',
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.tertiary),
            ],
          ),
        );
      },
    );
  }

  Widget _recentAnalysis() {
    return FutureBuilder<List<ApiAnalysisHistoryItem>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SkeletonRecentCard();
        }
        if (snapshot.hasError) {
          return AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Could not load recent analysis.',
                    style: TextStyle(color: context.textSubtle),
                  ),
                ),
                TextButton(
                  onPressed: _refreshHistory,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return AppCard(
            padding: const EdgeInsets.all(16),
            borderColor: context.primary.withValues(alpha: 0.2),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.primary.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    color: context.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No analyses yet. Start a symptom check to see your latest result here.',
                    style: TextStyle(color: context.textSubtle, fontSize: 13.5),
                  ),
                ),
              ],
            ),
          );
        }
        return _recentCard(items.first);
      },
    );
  }

  Widget _recentCard(ApiAnalysisHistoryItem item) {
    final level = appRiskLevelFor(item.triageLevel, item.riskScore);
    final color = level.color(context);

    return Tilt3DCard(
      onTap: () => _openHistoryItem(item),
      padding: const EdgeInsets.all(16),
      border: Border.all(color: color.withValues(alpha: 0.25)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(level.icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.triageLevel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.symptoms,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: context.textSubtle, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  formatHistoryDateTime(item.createdAt),
                  style: TextStyle(color: context.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.riskScore}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              Text(
                '/100',
                style: TextStyle(color: context.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 2),
          Icon(Icons.chevron_right_rounded, color: context.textMuted),
        ],
      ),
    );
  }

  Widget _emergencyPrompt() {
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.danger.withValues(alpha: 0.1),
            ),
            child: const Icon(Icons.emergency_rounded, color: AppColors.danger),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add an emergency contact',
                  style: TextStyle(
                    color: context.textMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Shown when a symptom check flags urgent risk',
                  style: TextStyle(color: context.textMuted, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.textMuted),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tilt3DCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          PulseAvatar3D(icon: icon, color: color, size: 40),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.textMain,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: context.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ThemeController.instance, Motion.instance]),
      builder: (context, _) {
        final dark = ThemeController.instance.themeMode == ThemeMode.dark;
        final motion = Motion.instance.enabled;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.textMain,
                      ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Dark mode',
                      style: TextStyle(color: context.textMain)),
                  subtitle: Text('Easier on the eyes at night',
                      style: TextStyle(color: context.textMuted, fontSize: 12.5)),
                  secondary: Icon(
                    dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: context.primary,
                  ),
                  value: dark,
                  onChanged: (_) => ThemeController.instance.toggleTheme(),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('3D motion effects',
                      style: TextStyle(color: context.textMain)),
                  subtitle: Text(
                    'Tilt, parallax and depth — turn off if you feel motion discomfort',
                    style:
                        TextStyle(color: context.textMuted, fontSize: 12.5),
                  ),
                  secondary: Icon(
                    Icons.view_in_ar_rounded,
                    color: context.primary,
                  ),
                  value: motion,
                  onChanged: (v) => Motion.instance.setEnabled(v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonRecentCard extends StatelessWidget {
  const _SkeletonRecentCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.surfaceMuted,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: context.surfaceMuted,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 90,
                  height: 12,
                  decoration: BoxDecoration(
                    color: context.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: context.primary,
            ),
          ),
        ],
      ),
    );
  }
}
