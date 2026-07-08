import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages player energy and daily streak.
///
/// Energy rules:
///   - Max = 50, starts full on fresh install.
///   - Each context discovery costs 1 energy.
///   - Review sessions cost 0 energy.
///   - Regenerates at 1 energy per minute (computed from elapsed time on load
///     + a periodic in-app timer while the app is open).
///
/// Streak rules:
///   - Increments by 1 the first time any learning activity (discovery or
///     review) occurs on a given calendar day.
///   - Resets to 0 if more than 1 day passes without any activity.
class EnergyService {
  static const String _stateKey = 'kivo.energy_state.v1';
  static const int maxEnergy = 50;

  // ---------------------------------------------------------------------------
  // Observable state (readable by any widget via Obx)
  // ---------------------------------------------------------------------------

  final RxInt energy = maxEnergy.obs;
  final RxInt streakDays = 0.obs;

  // ---------------------------------------------------------------------------
  // Private fields
  // ---------------------------------------------------------------------------

  int _savedEnergy = maxEnergy;
  DateTime _lastUpdatedAt = DateTime.now();
  DateTime? _lastActiveDate;
  bool _isInitialized = false;
  Timer? _regenTimer;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    _loadState(prefs.getString(_stateKey));
    _startRegenTimer();
    _isInitialized = true;
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Consumes [amount] energy. Returns `false` (and does nothing) if the
  /// current energy is below [amount].
  Future<bool> consumeEnergy(int amount) async {
    await initialize();
    if (energy.value < amount) return false;
    energy.value = (energy.value - amount).clamp(0, maxEnergy);
    _savedEnergy = energy.value;
    _lastUpdatedAt = DateTime.now();
    await _saveState();
    return true;
  }

  /// Records a learning activity. Increments [streakDays] once per calendar
  /// day; resets to 1 if the last activity was more than 1 day ago.
  Future<void> recordActivity() async {
    await initialize();
    final today = _dateOnly(DateTime.now());
    final lastActive = _lastActiveDate;

    if (lastActive == null) {
      streakDays.value = 1;
    } else {
      final diff = today.difference(_dateOnly(lastActive)).inDays;
      if (diff == 1) {
        streakDays.value += 1;
      } else if (diff > 1) {
        streakDays.value = 1;
      }
      // diff == 0: same calendar day → no change
    }
    _lastActiveDate = DateTime.now();
    await _saveState();
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  void _startRegenTimer() {
    _regenTimer?.cancel();
    _regenTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (energy.value < maxEnergy) {
        energy.value = (energy.value + 1).clamp(0, maxEnergy);
        _savedEnergy = energy.value;
        _lastUpdatedAt = DateTime.now();
        _saveState();
      }
    });
  }

  void _loadState(String? raw) {
    if (raw == null || raw.isEmpty) {
      energy.value = maxEnergy;
      return;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;

      final saved = (json['savedEnergy'] as num?)?.toInt() ?? maxEnergy;
      final lastUpdated =
          DateTime.tryParse(json['lastUpdatedAt']?.toString() ?? '') ??
          DateTime.now();
      streakDays.value = (json['streakDays'] as num?)?.toInt() ?? 0;

      final lastActiveDateStr = json['lastActiveDate']?.toString();
      _lastActiveDate =
          lastActiveDateStr != null
              ? DateTime.tryParse(lastActiveDateStr)
              : null;

      // Reset streak if more than 1 day of inactivity
      if (_lastActiveDate != null) {
        final today = _dateOnly(DateTime.now());
        if (today.difference(_dateOnly(_lastActiveDate!)).inDays > 1) {
          streakDays.value = 0;
        }
      }

      // Compute energy regenerated while the app was closed
      final minutesElapsed = DateTime.now().difference(lastUpdated).inMinutes;
      final currentEnergy = (saved + minutesElapsed).clamp(0, maxEnergy);
      _savedEnergy = currentEnergy;
      _lastUpdatedAt = DateTime.now();
      energy.value = currentEnergy;
    } catch (_) {
      // On any parse error fall back to full energy
      energy.value = maxEnergy;
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, Object?>{
      'savedEnergy': _savedEnergy,
      'lastUpdatedAt': _lastUpdatedAt.toIso8601String(),
      'streakDays': streakDays.value,
      'lastActiveDate': _lastActiveDate?.toIso8601String(),
    };
    await prefs.setString(_stateKey, jsonEncode(payload));
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  void dispose() {
    _regenTimer?.cancel();
  }
}
