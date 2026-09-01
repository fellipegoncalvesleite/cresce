import 'dart:convert';

import 'package:bebecare/models/growth.dart';
import 'package:bebecare/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final fixedNow = DateTime(2026, 8, 31, 12);

  Future<(SharedPreferences, AppState)> freshState() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs: prefs, now: () => fixedNow);
    await state.load();
    return (prefs, state);
  }

  test('fresh state seeds the Lia demo profile exactly once', () async {
    final (prefs, state) = await freshState();

    expect(state.isDemoProfile, isTrue);
    expect(state.babyName, 'Lia');
    expect(state.babyAgeMonths, 8);

    await state.updateBabyName('Lia editada');
    final reloaded = AppState(prefs: prefs, now: () => fixedNow);
    await reloaded.load();

    expect(reloaded.babyName, 'Lia editada');
    expect(reloaded.isDemoProfile, isTrue);
  });

  test('existing state is not overwritten by demo seeding', () async {
    SharedPreferences.setMockInitialValues({'baby_name': 'Theo'});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs: prefs, now: () => fixedNow);

    await state.load();

    expect(state.babyName, 'Theo');
    expect(state.isDemoProfile, isFalse);
    expect(state.growthHistory, isEmpty);
  });

  test(
    'adding measurements appends history and latest measurement stays compatible',
    () async {
      final (_, state) = await freshState();
      await state.setMeasurement(null);

      const older = GrowthMeasurement(
        weightKg: 6.0,
        lengthCm: 62,
        ageMonths: 4,
      );
      const newer = GrowthMeasurement(
        weightKg: 7.2,
        lengthCm: 67,
        ageMonths: 6,
      );

      await state.addGrowthMeasurement(older, recordedAt: DateTime(2026, 4, 1));
      await state.setMeasurement(newer);

      expect(state.growthHistory, hasLength(2));
      expect(state.measurement?.weightKg, newer.weightKg);
      expect(state.latestGrowthRecord?.measurement.weightKg, newer.weightKg);
    },
  );

  test('growth history is persisted and reloaded chronologically', () async {
    final (prefs, state) = await freshState();
    await state.setMeasurement(null);

    await state.addGrowthMeasurement(
      const GrowthMeasurement(weightKg: 8, lengthCm: 70, ageMonths: 8),
      recordedAt: DateTime(2026, 8, 31),
    );
    await state.addGrowthMeasurement(
      const GrowthMeasurement(weightKg: 6, lengthCm: 62, ageMonths: 4),
      recordedAt: DateTime(2026, 4, 30),
    );

    final reloaded = AppState(prefs: prefs, now: () => fixedNow);
    await reloaded.load();

    expect(reloaded.growthHistory, hasLength(2));
    expect(reloaded.growthHistory.first.measurement.ageMonths, 4);
    expect(reloaded.growthHistory.last.measurement.ageMonths, 8);
    expect(reloaded.measurement?.ageMonths, 8);
  });

  test('exact duplicate growth records are not appended twice', () async {
    final (_, state) = await freshState();
    await state.setMeasurement(null);
    const measurement = GrowthMeasurement(
      weightKg: 8,
      lengthCm: 70,
      ageMonths: 8,
    );
    final recordedAt = DateTime(2026, 8, 31, 10);

    await state.addGrowthMeasurement(measurement, recordedAt: recordedAt);
    await state.addGrowthMeasurement(measurement, recordedAt: recordedAt);

    expect(state.growthHistory, hasLength(1));
  });

  test('setMeasurement null clears the complete growth history', () async {
    final (_, state) = await freshState();

    expect(state.growthHistory, isNotEmpty);
    await state.setMeasurement(null);

    expect(state.growthHistory, isEmpty);
    expect(state.measurement, isNull);
    expect(state.growthStatus, isNull);
  });

  test('legacy single measurement migrates to growth history', () async {
    final legacy = const GrowthMeasurement(
      weightKg: 7.4,
      lengthCm: 68,
      ageMonths: 7,
    );
    SharedPreferences.setMockInitialValues({
      'growth_measurement': jsonEncode(legacy.toJson()),
    });
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs: prefs, now: () => fixedNow);

    await state.load();

    expect(state.growthHistory, hasLength(1));
    expect(state.measurement?.weightKg, 7.4);
    expect(state.latestGrowthRecord?.recordedAt, fixedNow);
    expect(prefs.getString('growth_history'), isNotNull);
  });

  test(
    'malformed legacy measurement does not crash or seed over existing data',
    () async {
      SharedPreferences.setMockInitialValues({
        'growth_measurement': '{definitely not json',
      });
      final prefs = await SharedPreferences.getInstance();
      final state = AppState(prefs: prefs, now: () => fixedNow);

      await state.load();

      expect(state.growthHistory, isEmpty);
      expect(state.measurement, isNull);
      expect(state.isDemoProfile, isFalse);
    },
  );

  test(
    'resetDemoData restores showcase data without resetting theme or preferences',
    () async {
      final (_, state) = await freshState();
      await state.setThemeMode(ThemeMode.dark);
      await state.setVaccineRemindersEnabled(false);
      await state.setWeeklyTipsEnabled(false);
      await state.setEmailNewsEnabled(true);
      await state.updateBabyName('Outro nome');

      await state.resetDemoData();

      expect(state.babyName, 'Lia');
      expect(state.babyAgeMonths, 8);
      expect(state.isDemoProfile, isTrue);
      expect(state.growthHistory.length, greaterThanOrEqualTo(4));
      expect(state.growthStatus, GrowthStatus.healthyRange);
      expect(state.themeMode, ThemeMode.dark);
      expect(state.vaccineRemindersEnabled, isFalse);
      expect(state.weeklyTipsEnabled, isFalse);
      expect(state.emailNewsEnabled, isTrue);
    },
  );

  test('settings preference toggles persist across AppState reload', () async {
    final (prefs, state) = await freshState();

    await state.setVaccineRemindersEnabled(false);
    await state.setWeeklyTipsEnabled(false);
    await state.setEmailNewsEnabled(true);

    final reloaded = AppState(prefs: prefs, now: () => fixedNow);
    await reloaded.load();

    expect(reloaded.vaccineRemindersEnabled, isFalse);
    expect(reloaded.weeklyTipsEnabled, isFalse);
    expect(reloaded.emailNewsEnabled, isTrue);
  });
}
