import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Thin, testable wrapper around flutter_local_notifications providing
/// daily-repeating reminders with timezone support and graceful fallbacks on
/// platforms that don't support scheduled notifications.
class NotificationScheduler {
  NotificationScheduler._();

  static final NotificationScheduler instance = NotificationScheduler._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  bool get isReady => _ready;

  static const String _medicationChannelId = 'medication_reminders';
  static const String _careStepsChannelId = 'care_steps';

  Future<void> init() async {
    if (_ready) return;
    try {
      tzdata.initializeTimeZones();
      // A pragmatic local offset: schedules fire relative to device local
      // time. TZDateTime.local handles the offset for us.
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      _ready = true;
    } catch (e) {
      debugPrint('NotificationScheduler init failed: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (!_ready) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Permission request failed: $e');
    }
    return false;
  }

  /// Schedules daily reminders for a medication. Notification ids are
  /// derived deterministically from the medication id + time so they can be
  /// cancelled reliably.
  Future<void> scheduleMedication({
    required String medicationId,
    required String name,
    required String dosage,
    required List<int> reminderMinutes,
  }) async {
    if (!_ready) return;
    try {
      await cancelMedication(medicationId);
      final hash = medicationId.hashCode & 0x7fffffff;
      for (var i = 0; i < reminderMinutes.length; i++) {
        final minutes = reminderMinutes[i];
        final id = (hash + i * 7) & 0x7fffffff;
        await _plugin.zonedSchedule(
          id,
          'Medication reminder',
          dosage.isEmpty
              ? 'Time to take $name'
              : 'Time to take $name — $dosage',
          _nextInstanceOf(minutes),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _medicationChannelId,
              'Medication reminders',
              channelDescription: 'Daily reminders to take your medication',
              importance: Importance.high,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(''),
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      debugPrint('scheduleMedication failed: $e');
    }
  }

  Future<void> cancelMedication(String medicationId) async {
    if (!_ready) return;
    try {
      final hash = medicationId.hashCode & 0x7fffffff;
      for (var i = 0; i < 12; i++) {
        await _plugin.cancel((hash + i * 7) & 0x7fffffff);
      }
    } catch (e) {
      debugPrint('cancelMedication failed: $e');
    }
  }

  /// Schedules follow-up care steps from an analysis result. Each step gets
  /// a reminder tomorrow at the same time so the user acts on advice.
  Future<void> scheduleCareStepFollowUps({
    required int analysisId,
    required List<String> steps,
  }) async {
    if (!_ready || steps.isEmpty) return;
    try {
      final base = (analysisId.hashCode & 0x7fffffff) | 0x1000;
      for (var i = 0; i < steps.length && i < 5; i++) {
        await _plugin.zonedSchedule(
          (base + i) & 0x7fffffff,
          'Care step ${i + 1} of ${steps.length}',
          steps[i],
          _nextInstanceOf(9 * 60 + i * 30), // staggered from 9:00
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _careStepsChannelId,
              'Care step follow-ups',
              channelDescription: 'Follow-ups for your AI care plan',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    } catch (e) {
      debugPrint('scheduleCareStepFollowUps failed: $e');
    }
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  tz.TZDateTime _nextInstanceOf(int minutesFromMidnight) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutesFromMidnight ~/ 60,
      minutesFromMidnight % 60,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
