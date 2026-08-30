import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import '../theme/ui_colors.dart';

/// First-aid quick reference carousel. Data-driven so adding a topic is a
/// one-line change. Purely informational.
class FirstAidCarousel extends StatefulWidget {
  final double height;

  const FirstAidCarousel({super.key, this.height = 180});

  @override
  State<FirstAidCarousel> createState() => _FirstAidCarouselState();
}

class _FirstAidCarouselState extends State<FirstAidCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _current = 0;

  static const List<FirstAidItem> _items = [
    FirstAidItem(
      icon: Icons.favorite_rounded,
      title: 'Chest Pain',
      color: AppColors.danger,
      description:
          'Call emergency services immediately. Keep the person seated, calm and avoid exertion.',
      callToAction: 'Call emergency services',
    ),
    FirstAidItem(
      icon: Icons.air_rounded,
      title: 'Breathing Difficulty',
      color: AppColors.urgent,
      description:
          'Loosen tight clothing, help the person sit upright, and call for help if severe or worsening.',
      callToAction: 'Seek urgent help if severe',
    ),
    FirstAidItem(
      icon: Icons.bolt_rounded,
      title: 'Seizure',
      color: AppColors.warning,
      description:
          'Do not restrain. Cushion the head, remove hazards, and time the seizure. Call for help.',
      callToAction: 'Call for help',
    ),
    FirstAidItem(
      icon: Icons.water_drop_rounded,
      title: 'Heavy Bleeding',
      color: AppColors.danger,
      description:
          'Apply firm pressure with a clean cloth. Elevate the area if possible and call emergency services.',
      callToAction: 'Call emergency services',
    ),
    FirstAidItem(
      icon: Icons.psychology_rounded,
      title: 'Stroke — FAST',
      color: AppColors.danger,
      description:
          'Face drooping, Arm weakness, Speech difficulty — Time to call emergency services immediately.',
      callToAction: 'Call immediately',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: _items.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final item = _items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _FirstAidCard(item: item),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: AppDimensions.fast,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? context.primary
                    : context.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class FirstAidItem {
  final IconData icon;
  final String title;
  final String description;
  final String callToAction;
  final Color color;

  const FirstAidItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.callToAction,
    required this.color,
  });
}

class _FirstAidCard extends StatelessWidget {
  final FirstAidItem item;

  const _FirstAidCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = item.color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.13),
                ),
                child: Icon(item.icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textMain,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              item.description,
              style: TextStyle(
                color: context.textSubtle,
                height: 1.45,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.call_rounded, color: accent, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.callToAction,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}