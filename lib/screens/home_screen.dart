import 'package:flutter/material.dart';

import '../core/date_format.dart';
import '../models/api_analysis_history_item.dart';
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
import 'ai_input_screen.dart';
import 'ai_outcome_screen.dart';
import 'analysis_history_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _historyService = AnalysisHistoryApiService();
  final _profileService = ProfileService();

  String _name = '';
  PatientProfile? _profile;
  late Future<List<ApiAnalysisHistoryItem>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _historyService.getHistory();
    _loadUser();
    _loadProfile();
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
        SnackBar(content: Text('Could not open that analysis.')),
      );
    }
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
                      subtitle: 'Quick reference for common emergencies',
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
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
          tooltip: 'Toggle theme',
          onPressed: () => ThemeController.instance.toggleTheme(),
          icon: const Icon(Icons.dark_mode_outlined),
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

  Widget _heroCta() {
    return EchoTap(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AiInputScreen()),
      ),
      semanticLabel: 'Start a symptom check',
      child: Container(
        height: 168,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles.
            Positioned(
              right: -34,
              top: -34,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: -6,
              bottom: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
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
    );
  }

  Widget _quickActions() {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            padding: const EdgeInsets.all(16),
            child: _QuickAction(
              icon: Icons.person_rounded,
              color: AppColors.secondary,
              title: 'Profile',
              subtitle: 'Conditions & contacts',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AnalysisHistoryScreen()),
            ),
            padding: const EdgeInsets.all(16),
            child: _QuickAction(
              icon: Icons.history_rounded,
              color: AppColors.tertiary,
              title: 'History',
              subtitle: 'Past results',
            ),
          ),
        ),
      ],
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

    return AppCard(
      onTap: () => _openHistoryItem(item),
      padding: const EdgeInsets.all(16),
      borderColor: color.withValues(alpha: 0.25),
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _QuickAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.textMain,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
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