import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_profile.dart';
import '../models/growth.dart';
import '../models/vaccine.dart';

/// App-wide local state persisted with shared_preferences.
class AppState extends ChangeNotifier {
  AppState({SharedPreferences? prefs, DateTime Function()? now})
    : _prefs = prefs,
      _now = now ?? DateTime.now;

  static const _kName = 'baby_name';
  static const _kBirth = 'baby_birth';
  static const _kLegacyGrowth = 'growth_measurement';
  static const _kGrowthHistory = 'growth_history';
  static const _kVaccines = 'vaccine_records';
  static const _kTheme = 'theme_mode';
  static const _kParent1 = 'parent1_name';
  static const _kParent2 = 'parent2_name';
  static const _kEmail = 'user_email';
  static const _kIsDemoProfile = 'is_demo_profile';
  static const _kDataVersion = 'demo_seed_version';
  static const _kVaccineReminders = 'pref_vaccine_reminders';
  static const _kWeeklyTips = 'pref_weekly_tips';
  static const _kEmailNews = 'pref_email_news';
  static const _currentDataVersion = 1;

  SharedPreferences? _prefs;
  final DateTime Function() _now;

  int _selectedIndex = 0;
  String _babyName = 'bebê';
  DateTime? _birthDate;
  ThemeMode _themeMode = ThemeMode.system;
  String _parent1Name = '';
  String _parent2Name = '';
  String? _userEmail;
  bool _isDemoProfile = false;
  bool _vaccineRemindersEnabled = true;
  bool _weeklyTipsEnabled = true;
  bool _emailNewsEnabled = false;
  final List<GrowthRecord> _growthHistory = [];
  final Map<String, VaccineRecord> _vaccineRecords = {};

  // --- getters ---
  int get selectedIndex => _selectedIndex;
  ThemeMode get themeMode => _themeMode;
  String get parent1Name => _parent1Name;
  String get parent2Name => _parent2Name;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _userEmail != null;
  String get babyName => _babyName;
  DateTime? get birthDate => _birthDate;
  bool get isDemoProfile => _isDemoProfile;
  bool get vaccineRemindersEnabled => _vaccineRemindersEnabled;
  bool get weeklyTipsEnabled => _weeklyTipsEnabled;
  bool get emailNewsEnabled => _emailNewsEnabled;

  /// Chronological growth history. Equal timestamps retain insertion order.
  List<GrowthRecord> get growthHistory {
    final indexed = _growthHistory.asMap().entries.toList()
      ..sort((a, b) {
        final byDate = a.value.recordedAt.compareTo(b.value.recordedAt);
        return byDate != 0 ? byDate : a.key.compareTo(b.key);
      });
    return List.unmodifiable(indexed.map((entry) => entry.value));
  }

  GrowthRecord? get latestGrowthRecord {
    final history = growthHistory;
    return history.isEmpty ? null : history.last;
  }

  /// Backwards-compatible convenience getter used by the existing Growth UI.
  GrowthMeasurement? get measurement => latestGrowthRecord?.measurement;
  GrowthStatus? get growthStatus => GrowthEstimator.estimate(measurement);

  /// Baby age in whole months, or null if no birth date is set.
  int? get babyAgeMonths {
    final birth = _birthDate;
    if (birth == null) return null;
    return wholeMonthsBetween(birth, _now());
  }

  VaccineRecord? recordFor(String vaccineId) => _vaccineRecords[vaccineId];

  /// Loads persisted state and performs one-time local migrations/seeding.
  Future<void> load() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final hadPriorAppData = _hasPriorAppData(prefs);

    _babyName = prefs.getString(_kName) ?? 'bebê';
    final birthRaw = prefs.getString(_kBirth);
    _birthDate = birthRaw != null ? DateTime.tryParse(birthRaw) : null;

    final themeRaw = prefs.getString(_kTheme);
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == themeRaw,
      orElse: () => ThemeMode.system,
    );

    _parent1Name = prefs.getString(_kParent1) ?? '';
    _parent2Name = prefs.getString(_kParent2) ?? '';
    _userEmail = prefs.getString(_kEmail);
    _isDemoProfile = prefs.getBool(_kIsDemoProfile) ?? false;
    _vaccineRemindersEnabled = prefs.getBool(_kVaccineReminders) ?? true;
    _weeklyTipsEnabled = prefs.getBool(_kWeeklyTips) ?? true;
    _emailNewsEnabled = prefs.getBool(_kEmailNews) ?? false;

    await _loadGrowthHistory(prefs);
    _loadVaccineRecords(prefs);

    if (!hadPriorAppData && !prefs.containsKey(_kDataVersion)) {
      await _applyDemoData(prefs, buildDemoProfile(now: _now()));
    } else if (!prefs.containsKey(_kDataVersion)) {
      await prefs.setInt(_kDataVersion, _currentDataVersion);
    }

    notifyListeners();
  }

  bool _hasPriorAppData(SharedPreferences prefs) {
    const keys = <String>{
      _kName,
      _kBirth,
      _kLegacyGrowth,
      _kGrowthHistory,
      _kVaccines,
      _kTheme,
      _kParent1,
      _kParent2,
      _kEmail,
      _kIsDemoProfile,
      _kDataVersion,
      _kVaccineReminders,
      _kWeeklyTips,
      _kEmailNews,
    };
    return keys.any(prefs.containsKey);
  }

  Future<void> _loadGrowthHistory(SharedPreferences prefs) async {
    _growthHistory.clear();
    final historyRaw = prefs.getString(_kGrowthHistory);

    if (historyRaw != null) {
      try {
        final decoded = jsonDecode(historyRaw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map) continue;
            final record = GrowthRecord.fromJson(
              Map<String, dynamic>.from(item),
            );
            if (record != null) _growthHistory.add(record);
          }
        }
      } catch (_) {
        _growthHistory.clear();
      }
      return;
    }

    final legacyRaw = prefs.getString(_kLegacyGrowth);
    if (legacyRaw == null) return;

    try {
      final decoded = jsonDecode(legacyRaw);
      if (decoded is! Map) return;
      final measurement = GrowthMeasurement.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      if (measurement == null) return;

      _growthHistory.add(
        GrowthRecord(measurement: measurement, recordedAt: _now()),
      );
      await _persistGrowthHistory();
      await prefs.remove(_kLegacyGrowth);
    } catch (_) {
      _growthHistory.clear();
    }
  }

  void _loadVaccineRecords(SharedPreferences prefs) {
    _vaccineRecords.clear();
    final vaccinesRaw = prefs.getString(_kVaccines);
    if (vaccinesRaw == null) return;

    try {
      final map = jsonDecode(vaccinesRaw) as Map<String, dynamic>;
      map.forEach((key, value) {
        if (value is Map) {
          _vaccineRecords[key] = VaccineRecord.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    } catch (_) {
      _vaccineRecords.clear();
    }
  }

  // --- mutations ---
  void selectTab(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _prefs?.setString(_kTheme, mode.name);
  }

  /// Flip between light and dark based on what's currently showing.
  Future<void> toggleTheme(Brightness current) => setThemeMode(
    current == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
  );

  Future<void> updateBabyName(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty || normalized == _babyName) return;
    _babyName = normalized;
    notifyListeners();
    await _prefs?.setString(_kName, _babyName);
  }

  Future<void> setParents({String? parent1, String? parent2}) async {
    if (parent1 != null) _parent1Name = parent1.trim();
    if (parent2 != null) _parent2Name = parent2.trim();
    notifyListeners();
    await _prefs?.setString(_kParent1, _parent1Name);
    await _prefs?.setString(_kParent2, _parent2Name);
  }

  /// Fake sign-in: there is no backend; the email is stored locally only.
  Future<void> login(String email) async {
    _userEmail = email.trim();
    notifyListeners();
    await _prefs?.setString(_kEmail, _userEmail!);
  }

  Future<void> logout() async {
    _userEmail = null;
    notifyListeners();
    await _prefs?.remove(_kEmail);
  }

  Future<void> setBirthDate(DateTime? date) async {
    _birthDate = date;
    notifyListeners();
    if (date == null) {
      await _prefs?.remove(_kBirth);
    } else {
      await _prefs?.setString(_kBirth, date.toIso8601String());
    }
  }

  Future<void> addGrowthMeasurement(
    GrowthMeasurement measurement, {
    DateTime? recordedAt,
  }) async {
    final record = GrowthRecord(
      measurement: measurement,
      recordedAt: recordedAt ?? _now(),
    );
    if (_growthHistory.any((existing) => _sameGrowthRecord(existing, record))) {
      return;
    }

    _growthHistory.add(record);
    notifyListeners();
    await _persistGrowthHistory();
  }

  /// Existing call sites keep working: non-null appends, null clears history.
  Future<void> setMeasurement(GrowthMeasurement? measurement) async {
    if (measurement == null) {
      if (_growthHistory.isEmpty) return;
      _growthHistory.clear();
      notifyListeners();
      await _prefs?.remove(_kGrowthHistory);
      await _prefs?.remove(_kLegacyGrowth);
      return;
    }
    await addGrowthMeasurement(measurement);
  }

  bool _sameGrowthRecord(GrowthRecord a, GrowthRecord b) {
    final am = a.measurement;
    final bm = b.measurement;
    return a.recordedAt == b.recordedAt &&
        am.weightKg == bm.weightKg &&
        am.lengthCm == bm.lengthCm &&
        am.ageMonths == bm.ageMonths;
  }

  Future<void> _persistGrowthHistory() async {
    final encoded = growthHistory.map((record) => record.toJson()).toList();
    await _prefs?.setString(_kGrowthHistory, jsonEncode(encoded));
  }

  Future<void> setVaccineTaken(
    String vaccineId, {
    required bool taken,
    DateTime? date,
  }) async {
    if (taken) {
      _vaccineRecords[vaccineId] = VaccineRecord(
        taken: true,
        takenDate: date ?? _now(),
      );
    } else {
      _vaccineRecords.remove(vaccineId);
    }
    notifyListeners();
    await _persistVaccines();
  }

  Future<void> setVaccineRemindersEnabled(bool value) async {
    if (_vaccineRemindersEnabled == value) return;
    _vaccineRemindersEnabled = value;
    notifyListeners();
    await _prefs?.setBool(_kVaccineReminders, value);
  }

  Future<void> setWeeklyTipsEnabled(bool value) async {
    if (_weeklyTipsEnabled == value) return;
    _weeklyTipsEnabled = value;
    notifyListeners();
    await _prefs?.setBool(_kWeeklyTips, value);
  }

  Future<void> setEmailNewsEnabled(bool value) async {
    if (_emailNewsEnabled == value) return;
    _emailNewsEnabled = value;
    notifyListeners();
    await _prefs?.setBool(_kEmailNews, value);
  }

  /// Replaces profile/showcase content with a fresh Lia sample dataset.
  /// Theme and user preference toggles are deliberately preserved.
  Future<void> resetDemoData() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await _applyDemoData(prefs, buildDemoProfile(now: _now()));
    notifyListeners();
  }

  Future<void> _applyDemoData(
    SharedPreferences prefs,
    DemoProfileData demo,
  ) async {
    _babyName = demo.babyName;
    _birthDate = demo.birthDate;
    _parent1Name = demo.parent1Name;
    _parent2Name = demo.parent2Name;
    _userEmail = demo.email;
    _isDemoProfile = true;
    _growthHistory
      ..clear()
      ..addAll(demo.growthHistory);
    _vaccineRecords
      ..clear()
      ..addAll(demo.vaccineRecords);

    await prefs.setString(_kName, _babyName);
    await prefs.setString(_kBirth, _birthDate!.toIso8601String());
    await prefs.setString(_kParent1, _parent1Name);
    await prefs.setString(_kParent2, _parent2Name);
    await prefs.setString(_kEmail, _userEmail!);
    await prefs.setBool(_kIsDemoProfile, true);
    await prefs.setInt(_kDataVersion, _currentDataVersion);
    await prefs.remove(_kLegacyGrowth);
    await _persistGrowthHistory();
    await _persistVaccines();
  }

  Future<void> _persistVaccines() async {
    final map = _vaccineRecords.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await _prefs?.setString(_kVaccines, jsonEncode(map));
  }
}
