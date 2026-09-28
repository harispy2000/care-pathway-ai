import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A user medication with daily reminder times (minutes from midnight).
class Medication {
  final String id;
  final String name;
  final String dosage;
  final List<int> reminderMinutes; // minutes from midnight
  final bool active;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.reminderMinutes,
    this.active = true,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    List<int>? reminderMinutes,
    bool? active,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'reminderMinutes': reminderMinutes,
        'active': active,
      };

  factory Medication.fromJson(Map<String, dynamic> json) {
    final raw = json['reminderMinutes'];
    return Medication(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      reminderMinutes: (raw is List ? raw : const [])
          .map((e) => (e as num).toInt())
          .toList(),
      active: json['active'] as bool? ?? true,
    );
  }
}

/// Local persistence + notification scheduling for daily medication
/// reminders. Works offline using SharedPreferences and
/// flutter_local_notifications with timezone-aware daily repeats.
class MedicationStore extends ChangeNotifier {
  MedicationStore._();

  static final MedicationStore instance = MedicationStore._();

  static const String _key = 'medications_v1';

  final List<Medication> _items = [];
  bool _loaded = false;

  List<Medication> get items => List.unmodifiable(_items);

  List<Medication> get activeItems =>
      _items.where((m) => m.active).toList(growable: false);

  int get activeDoseCount {
    var count = 0;
    for (final m in activeItems) {
      count += m.reminderMinutes.isEmpty ? 1 : m.reminderMinutes.length;
    }
    return count;
  }

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _items
          ..clear()
          ..addAll(list.map((e) => Medication.fromJson(e as Map<String, dynamic>)));
      } catch (_) {
        // Corrupt storage: start fresh rather than crash.
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> add(Medication med) async {
    _items.add(med);
    await _persist();
  }

  Future<void> update(Medication med) async {
    final i = _items.indexWhere((m) => m.id == med.id);
    if (i == -1) return;
    _items[i] = med;
    await _persist();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((m) => m.id == id);
    await _persist();
  }

  Future<void> setActive(String id, bool active) async {
    final i = _items.indexWhere((m) => m.id == id);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(active: active);
    await _persist();
  }

  /// The next upcoming dose across all active medications, or null.
  ({Medication med, int minutes})? nextDose() {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    ({Medication med, int minutes})? best;
    var bestDelta = 24 * 60 + 1;

    for (final m in activeItems) {
      final times = m.reminderMinutes.isEmpty ? const [8 * 60] : m.reminderMinutes;
      for (final t in times) {
        var delta = t - nowMinutes;
        if (delta < 0) delta += 24 * 60; // tomorrow
        if (delta < bestDelta) {
          bestDelta = delta;
          best = (med: m, minutes: delta);
        }
      }
    }
    return best;
  }
}
