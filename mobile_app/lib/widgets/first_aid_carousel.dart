import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_dimensions.dart';
import '../theme/ui_colors.dart';

/// First-aid quick reference carousel rendered as a 3D coverflow: side cards
/// rotate away and sink back; tapping flips the front card for full details.
class FirstAidCarousel extends StatefulWidget {
  final double height;

  const FirstAidCarousel({super.key, this.height = 210});

  @override
  State<FirstAidCarousel> createState() => _FirstAidCarouselState();
}

class _FirstAidCarouselState extends State<FirstAidCarousel> {
  final PageController _controller = PageController(
    viewportFraction: 0.82,
    initialPage: 0,
  );
  int _current = 0;

  static const List<FirstAidItem> _items = [
    FirstAidItem(
      icon: Icons.favorite_rounded,
      title: 'Chest Pain',
      color: AppColors.danger,
      description:
          'Call emergency services immediately. Keep the person seated, calm and avoid exertion.',
      callToAction: 'Call emergency services',
      steps: [
        'Call emergency services (or ask someone else to).',
        'Sit the person down, half-upright, and keep them calm.',
        'Loosen tight clothing; do not let them walk around.',
        'If they collapse and are not breathing, start CPR.',
      ],
    ),
    FirstAidItem(
      icon: Icons.air_rounded,
      title: 'Breathing Difficulty',
      color: AppColors.urgent,
      description:
          'Loosen tight clothing, help the person sit upright, and call for help if severe or worsening.',
      callToAction: 'Seek urgent help if severe',
      steps: [
        'Help them sit upright — leaning slightly forward helps.',
        'Loosen tight clothing and open a window for fresh air.',
        'Ask about inhalers or prescribed medication.',
        'Call emergency services if lips turn blue or speech is broken.',
      ],
    ),
    FirstAidItem(
      icon: Icons.bolt_rounded,
      title: 'Seizure',
      color: AppColors.warning,
      description:
          'Do not restrain. Cushion the head, remove hazards, and time the seizure. Call for help.',
      callToAction: 'Call for help',
      steps: [
        'Do not restrain the person or put anything in their mouth.',
        'Cushion the head and clear hard or sharp objects away.',
        'Time the seizure — over 5 minutes warrants an ambulance.',
        'After it ends, turn them on their side and stay with them.',
      ],
    ),
    FirstAidItem(
      icon: Icons.water_drop_rounded,
      title: 'Heavy Bleeding',
      color: AppColors.danger,
      description:
          'Apply firm pressure with a clean cloth. Elevate the area if possible and call emergency services.',
      callToAction: 'Call emergency services',
      steps: [
        'Apply firm, continuous pressure with a clean cloth.',
        'Elevate the injured area above heart level if possible.',
        'Do not remove soaked dressings — add more on top.',
        'Keep the person warm and still while help arrives.',
      ],
    ),
    FirstAidItem(
      icon: Icons.psychology_rounded,
      title: 'Stroke — FAST',
      color: AppColors.danger,
      description:
          'Face drooping, Arm weakness, Speech difficulty — Time to call emergency services immediately.',
      callToAction: 'Call immediately',
      steps: [
        'F — Face: ask them to smile; check for drooping.',
        'A — Arms: ask them to raise both; watch for drift.',
        'S — Speech: listen for slurred or confused speech.',
        'T — Time: note the time and call emergency services now.',
      ],
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
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _current = i);
            },
            itemBuilder: (context, index) {
              final item = _items[index];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double pageDelta = 0;
                  if (_controller.position.haveDimensions) {
                    pageDelta =
                        (_controller.page ?? _controller.initialPage.toDouble()) -
                            index;
                  }
                  pageDelta = pageDelta.clamp(-1.0, 1.0);

                  final angle = pageDelta * 0.55; // radians
                  final depth = pageDelta.abs();

                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.0022)
                    ..rotateY(angle);

                  return Opacity(
                    opacity: 1.0 - depth * 0.45,
                    child: Transform(
                      transform: transform,
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: 1.0 - depth * 0.12,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: _FlipFirstAidCard(item: item),
                ),
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
  final List<String> steps;

  const FirstAidItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.callToAction,
    required this.color,
    this.steps = const [],
  });
}

/// Front card flips in 3D to a detailed back face when tapped.
class _FlipFirstAidCard extends StatefulWidget {
  final FirstAidItem item;

  const _FlipFirstAidCard({required this.item});

  @override
  State<_FlipFirstAidCard> createState() => _FlipFirstAidCardState();
}

class _FlipFirstAidCardState extends State<_FlipFirstAidCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  bool _showBack = false;

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    if (_showBack) {
      _flip.reverse();
    } else {
      _flip.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _flip,
        builder: (context, _) {
          final angle = _flip.value * math.pi;
          final showBack = _flip.value > 0.5;

          Widget face(bool isBack) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0022)
                ..rotateY(isBack ? angle - math.pi : angle),
              child: Opacity(
                opacity: (isBack == showBack) ? 1.0 : 0.0,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: isBack
                      ? _FirstAidBackCard(item: widget.item)
                      : _FirstAidFrontCard(item: widget.item),
                ),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              if (showBack) face(true) else face(false),
            ],
          );
        },
      ),
    );
  }
}

class _FirstAidFrontCard extends StatelessWidget {
  final FirstAidItem item;

  const _FirstAidFrontCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = item.color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
              Icon(
                Icons.flip_rounded,
                size: 18,
                color: context.textMuted,
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
              Text(
                'Tap for steps',
                style: TextStyle(
                  color: context.textMuted,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FirstAidBackCard extends StatelessWidget {
  final FirstAidItem item;

  const _FirstAidBackCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = item.color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: context.isDarkMode ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, color: accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.title} — steps',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: context.textMain,
                  ),
                ),
              ),
              Icon(
                Icons.flip_rounded,
                size: 16,
                color: context.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < item.steps.length; i++)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.16),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: accent,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.steps[i],
                          style: TextStyle(
                            color: context.textSubtle,
                            height: 1.35,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
