import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/ui_colors.dart';
import 'app_button.dart';

/// Emergency safety alert with an optional saved emergency contact and a
/// direct dial action.
class EmergencyContactCard extends StatelessWidget {
  final String? contactName;
  final String? contactNumber;

  const EmergencyContactCard({
    super.key,
    this.contactName,
    this.contactNumber,
  });

  Future<void> _call(BuildContext context) async {
    final number = contactNumber?.trim() ?? '';
    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No emergency contact saved yet')),
      );
      return;
    }
    final uri = Uri(
      scheme: 'tel',
      path: number.replaceAll(RegExp(r'[^0-9+]'), ''),
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  bool get _hasContact =>
      (contactName?.isNotEmpty ?? false) || (contactNumber?.isNotEmpty ?? false);

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.danger;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emergency_rounded, color: AppColors.danger),
              SizedBox(width: 8),
              Text(
                'Emergency Safety Alert',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'If symptoms are severe, worsening, or life-threatening, seek urgent medical help.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (_hasContact) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: context.isDarkMode ? 0.04 : 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.contact_emergency_rounded,
                    color: AppColors.danger,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contactName?.isNotEmpty == true
                              ? contactName!
                              : 'Emergency contact',
                          style: TextStyle(
                            color: context.textMain,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          contactNumber?.isNotEmpty == true
                              ? contactNumber!
                              : 'No number saved',
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
            ),
          ],
          const SizedBox(height: 12),
          AppIconActionButton(
            label: 'Call Emergency Contact',
            icon: Icons.call_rounded,
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            onPressed: () => _call(context),
          ),
        ],
      ),
    );
  }
}