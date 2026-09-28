import 'package:flutter/material.dart';

import '../core/date_format.dart';
import '../core/errors.dart';
import '../models/api_analysis_history_item.dart';
import '../services/analysis_history_api_service.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_risk.dart';
import '../theme/ui_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_state.dart';
import 'ai_input_screen.dart';
import 'ai_outcome_screen.dart';

class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({super.key});

  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final _service = AnalysisHistoryApiService();
  late Future<List<ApiAnalysisHistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getHistory();
  }

  Future<void> _refresh() async {
    final future = _service.getHistory();
    setState(() => _future = future);
    await future;
  }

  Future<void> _open(ApiAnalysisHistoryItem item) async {
    try {
      final response = await _service.getHistoryById(item.id);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AiOutcomeScreen(response: response)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.screenBg,
      appBar: AppBar(title: const Text('Analysis History')),
      body: FutureBuilder<List<ApiAnalysisHistoryItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: context.primary,
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return AppEmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load history',
              message: 'Check your connection and try again.',
              action: AppButton(
                label: 'Retry',
                icon: Icons.refresh_rounded,
                variant: AppButtonVariant.outline,
                minHeight: 46,
                onPressed: _refresh,
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return AppEmptyState(
              icon: Icons.history_rounded,
              title: 'No analyses yet',
              message:
                  'Start a symptom check and your results will appear here.',
              action: AppButton(
                label: 'Start symptom check',
                icon: Icons.psychology_alt_rounded,
                minHeight: 48,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiInputScreen()),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _historyList(items),
          );
        },
      ),
    );
  }

  Widget _historyList(List<ApiAnalysisHistoryItem> items) {
    final groups = <String, List<ApiAnalysisHistoryItem>>{};
    for (final item in items) {
      final d = item.createdAt.toLocal();
      final key = '${d.year}-${d.month}-${d.day}';
      groups.putIfAbsent(key, () => []).add(item);
    }
    final dayKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    final children = <Widget>[];
    for (final key in dayKeys) {
      children.add(_dayHeader(groups[key]!.first.createdAt));
      children.addAll(groups[key]!.map((e) => _historyCard(e)));
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _dayHeader(DateTime createdAt) {
    final now = DateTime.now();
    final d = createdAt.toLocal();
    final sameDay = (DateTime(now.year, now.month, now.day) ==
        DateTime(d.year, d.month, d.day));

    String label;
    if (sameDay) {
      label = 'Today';
    } else if (DateTime(now.year, now.month, now.day).difference(
          DateTime(d.year, d.month, d.day),
        ).inDays ==
        1) {
      label = 'Yesterday';
    } else {
      label = '${d.day} ${_monthNames[d.month - 1]} ${d.year}';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: context.textMuted,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: context.softBorder, height: 1),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(ApiAnalysisHistoryItem item) {
    final level = appRiskLevelFor(item.triageLevel, item.riskScore);
    final color = level.color(context);

    return AppCard(
      onTap: () => _open(item),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      borderColor: color.withValues(alpha: 0.22),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(level.icon, color: color, size: 24),
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
                  fontSize: 19,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '/100',
                style: TextStyle(color: context.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: context.textMuted),
        ],
      ),
    );
  }
}