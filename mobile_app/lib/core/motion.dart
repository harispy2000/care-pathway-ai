import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global 3D-motion system.
///
/// - Listens to the gyroscope (mobile only) and exposes a smoothed tilt
///   vector in the -1..1 range used by parallax layers.
/// - Lets the user flatten all 3D effects with one toggle (also provides a
///   programmatic tilt source for web/desktop where no gyroscope exists).
class Motion extends ChangeNotifier {
  Motion._();

  static final Motion instance = Motion._();

  static const String _enabledKey = 'motion_3d_enabled';

  StreamSubscription<GyroscopeEvent>? _gyroSub;
  Timer? _decayTimer;

  double _x = 0;
  double _y = 0;
  bool _enabled = true;

  /// Horizontal tilt, roughly -1..1. Positive = device tilts right.
  double get x => _enabled ? _x : 0;

  /// Vertical tilt, roughly -1..1. Positive = device tilts toward the user.
  double get y => _enabled ? _y : 0;

  /// Master switch so motion can be reduced for comfort or accessibility.
  bool get enabled => _enabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
    _startListening();
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);

    if (!value) {
      _x = 0;
      _y = 0;
      _stopListening();
    } else {
      _startListening();
    }
    notifyListeners();
  }

  void toggle() => setEnabled(!enabled);

  /// Programmatic tilt source for platforms without a gyroscope (web,
  /// desktop, emulators). Values are clamped to -1..1.
  void setTilt(double x, double y) {
    if (!_enabled) return;
    _x = x.clamp(-1.0, 1.0);
    _y = y.clamp(-1.0, 1.0);
    notifyListeners();
  }

  void _startListening() {
    if (_gyroSub != null || kIsWeb) {
      // No gyro on web/desktop: parallax layers still react to setTilt.
      return;
    }
    try {
      _gyroSub = gyroscopeEventStream(samplingPeriod: const Duration(milliseconds: 50))
          .listen(_onGyro, onError: (_) {});
    } catch (_) {
      // Sensor unavailable; effects simply stay static.
    }
  }

  void _stopListening() {
    _gyroSub?.cancel();
    _gyroSub = null;
    _decayTimer?.cancel();
    _decayTimer = null;
  }

  void _onGyro(GyroscopeEvent event) {
    // Gyroscope returns angular velocity (rad/s). Integrate a decaying
    // estimate so a flick of the wrist nudges the scene and it drifts
    // back to rest when the device is still.
    const double responsiveness = 0.12;
    const double damping = 0.90;
    const double max = 1.0;

    double nx = (_x + (-event.y) * responsiveness) * damping;
    double ny = (_y + (-event.x) * responsiveness) * damping;
    _x = nx.clamp(-max, max);
    _y = ny.clamp(-max, max);
    notifyListeners();
  }

  /// Idle decay toward zero when no sensor is producing events.
  void decay() {
    if (_x == 0 && _y == 0) return;
    _x *= 0.92;
    _y *= 0.92;
    if (_x.abs() < 0.005 && _y.abs() < 0.005) {
      _x = 0;
      _y = 0;
    }
    notifyListeners();
  }
}

/// Convenience wrapper that plays an entrance animation for any widget.
class MotionReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Offset offset;

  const MotionReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.08),
  });

  @override
  State<MotionReveal> createState() => _MotionRevealState();
}

class _MotionRevealState extends State<MotionReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: Tween<Offset>(begin: widget.offset, end: Offset.zero)
            .animate(_fade),
        child: widget.child,
      ),
    );
  }
}
