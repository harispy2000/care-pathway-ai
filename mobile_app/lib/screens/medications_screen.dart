import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/medication.dart';
import '../services/notification_scheduler.dart';
import '../theme/ui_colors.dart';
import '../widgets/echo_tap.dart';
import '../widgets/tilt_3d_card.dart';

/// Manage daily medication reminders with local notifications.
class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final _store = MedicationStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  Future<void> _openEditor([Medication? existing]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MedicationEditorSheet(existing: existing),
    );
    if (saved == true && mounted) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> _toggle(Medication med, bool active) async {
    HapticFeedback.selectionClick();
    final updated = med.copyWith(active: active);
    await _store.setActive(med.id, active);
    if (!updated.active) {
      await NotificationScheduler.instance.cancelMedication(med.id);
    } else {
      await NotificationScheduler.instance.scheduleMedication(
        medicationId: updated.id,
        name: updated.name,
        dosage: updated.dosage,
        reminderMinutes: updated.reminderMinutes,
      );
    }
  }

  Future<void> _delete(Medication med) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove medication?'),
        content: Text('${med.name} and its reminders will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await NotificationScheduler.instance.cancelMedication(med.id);
      await _store.remove(med.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.screenBg,
      appBar: AppBar(title: const Text('Medication Reminders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEditor,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add medication'),
      ),
      body: AnimatedBuilder(
        animation: _store,
        builder: (context, _) {
          if (_store.items.isEmpty) {
            return _EmptyReminders(onAdd: () => _openEditor());
          }
          final next = _store.nextDose();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            physics: const BouncingScrollPhysics(),
            children: [
              _NextDoseCard(next: next),
              const SizedBox(height: 16),
              for (final med in _store.items)
                _MedicationCard(
                  med: med,
                  onToggle: _toggle,
                  onEdit: _openEditor,
                  onDelete: _delete,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication med;
  final void Function(Medication, bool) onToggle;
  final void Function(Medication) onEdit;
  final void Function(Medication) onDelete;

  const _MedicationCard({
    required this.med,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:${m.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final accent = med.active ? context.primary : context.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Tilt3DCard(
        onTap: () => onEdit(med),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            PulseAvatar3D(
              icon: Icons.medication_rounded,
              color: accent,
              size: 40,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: TextStyle(
                      color: context.textMain,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    med.dosage.isEmpty ? 'No dosage set' : med.dosage,
                    style: TextStyle(color: context.textMuted, fontSize: 12.5),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in med.reminderMinutes)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatTime(t),
                            style: TextStyle(
                              color: accent,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (med.reminderMinutes.isEmpty)
                        Text(
                          'No reminders scheduled',
                          style:
                              TextStyle(color: context.textMuted, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: med.active,
                  onChanged: (v) => onToggle(med, v),
                ),
                EchoTap(
                  onTap: () => onDelete(med),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger.withValues(alpha: 0.75),
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NextDoseCard extends StatelessWidget {
  final ({Medication med, int minutes})? next;

  const _NextDoseCard({required this.next});

  @override
  Widget build(BuildContext context) {
    final hours = (next?.minutes ?? 0) ~/ 60;
    final minutes = (next?.minutes ?? 0) % 60;

    return Tilt3DCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [context.primary, AppColors.primaryDark],
      ),
      border: Border.all(color: Colors.transparent),
      showSheen: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PulseAvatar3D(
                icon: Icons.alarm_rounded,
                color: Colors.white,
                iconColor: AppColors.primaryDark,
                size: 38,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Next dose',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            next == null
                ? 'Nothing scheduled'
                : '${next!.med.name} in ${hours}h ${minutes.toString().padLeft(2, '0')}m',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            next == null
                ? 'Add a medication to start reminders'
                : 'Staying on schedule helps your care plan work',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReminders extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyReminders({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PulseAvatar3D(
              icon: Icons.medication_liquid_rounded,
              color: AppColors.primary,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'No medications yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.textMain,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your medications and we will remind you at the right time every day — even offline.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.textMuted, height: 1.5),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add first medication'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationEditorSheet extends StatefulWidget {
  final Medication? existing;

  const _MedicationEditorSheet({this.existing});

  @override
  State<_MedicationEditorSheet> createState() => _MedicationEditorSheetState();
}

class _MedicationEditorSheetState extends State<_MedicationEditorSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _dosage =
      TextEditingController(text: widget.existing?.dosage ?? '');
  late final List<int> _times =
      (widget.existing?.reminderMinutes.isNotEmpty ?? false)
          ? List.of(widget.existing!.reminderMinutes)
          : [8 * 60];

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    super.dispose();
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    if (!_times.contains(minutes)) {
      setState(() {
        _times.add(minutes);
        _times.sort();
      });
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    final store = MedicationStore.instance;
    final id = widget.existing?.id ??
        DateTime.now().microsecondsSinceEpoch.toString();

    final med = Medication(
      id: id,
      name: _name.text.trim(),
      dosage: _dosage.text.trim(),
      reminderMinutes: _times,
      active: widget.existing?.active ?? true,
    );

    if (widget.existing == null) {
      await store.add(med);
    } else {
      await store.update(med);
    }

    await NotificationScheduler.instance.requestPermissions();
    await NotificationScheduler.instance.scheduleMedication(
      medicationId: med.id,
      name: med.name,
      dosage: med.dosage,
      reminderMinutes: med.reminderMinutes,
    );

    if (mounted) Navigator.pop(context, true);
  }

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:${m.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Add medication' : 'Edit medication',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: context.textMain,
                  ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Medication name',
                prefixIcon: Icon(Icons.medication_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: widget.existing == null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _dosage,
              decoration: const InputDecoration(
                labelText: 'Dosage (optional)',
                prefixIcon: Icon(Icons.science_outlined),
                hintText: 'e.g. 500 mg, 1 tablet',
              ),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(
                  'Reminder times',
                  style: TextStyle(
                    color: context.textSubtle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addTime,
                  icon: const Icon(Icons.add_alarm_rounded, size: 18),
                  label: const Text('Add time'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _times)
                  InputChip(
                    label: Text(_formatTime(t)),
                    onDeleted: _times.length > 1
                        ? () => setState(() => _times.remove(t))
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _name.text.trim().isEmpty ? null : _save,
              icon: const Icon(Icons.notifications_active_rounded),
              label: const Text('Save & schedule reminders'),
            ),
          ],
        ),
      ),
    );
  }
}
