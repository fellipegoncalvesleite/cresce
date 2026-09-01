import 'package:bebecare/data/baby_messages.dart';
import 'package:bebecare/data/baby_tips.dart';
import 'package:bebecare/data/demo_profile.dart';
import 'package:bebecare/data/vaccine_schedule.dart';
import 'package:bebecare/models/growth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tipsForAge returns only tips applicable to the requested age', () {
    final tips = tipsForAge(7);

    expect(tips, isNotEmpty);
    expect(tips.every((tip) => tip.ageRange.contains(7)), isTrue);
  });

  test('tipsForAge returns safe generic tips when age is unknown', () {
    final tips = tipsForAge(null);

    expect(tips, isNotEmpty);
    expect(tips, genericBabyTips);
  });

  test('tipForDay is deterministic for the same date and age', () {
    final date = DateTime(2026, 9, 1, 23, 59);

    final first = tipForDay(date: date, ageMonths: 8);
    final second = tipForDay(date: date, ageMonths: 8);

    expect(second.id, first.id);
    expect(second.text, first.text);
    expect(first.ageRange.contains(8), isTrue);
  });

  test('tipForDay falls back safely when age has no curated matches', () {
    final unknown = tipForDay(date: DateTime(2026, 9, 1), ageMonths: null);
    final outsideRange = tipForDay(date: DateTime(2026, 9, 1), ageMonths: 120);

    expect(genericBabyTips, contains(unknown));
    expect(genericBabyTips, contains(outsideRange));
  });

  test('messageForDay is deterministic for the same date and age', () {
    final date = DateTime(2026, 8, 31);

    final first = messageForDay(date: date, ageMonths: 8);
    final second = messageForDay(date: date, ageMonths: 8);

    expect(second.id, first.id);
    expect(second.text, first.text);
  });

  test('calendar month subtraction clamps invalid days safely', () {
    expect(
      subtractCalendarMonths(DateTime(2026, 10, 31), 8),
      DateTime(2026, 2, 28),
    );
  });

  test('demo profile is approximately eight months old at seed time', () {
    final now = DateTime(2026, 8, 31, 12);
    final demo = buildDemoProfile(now: now);

    expect(demo.babyName, 'Lia');
    expect(demo.parent1Name, 'Marina');
    expect(demo.parent2Name, 'Rafael');
    expect(demo.email, 'familia.lia@exemplo.com');
    expect(wholeMonthsBetween(demo.birthDate, now), 8);
  });

  test('demo growth history is ordered and latest record is healthy range', () {
    final demo = buildDemoProfile(now: DateTime(2026, 8, 31, 12));

    expect(demo.growthHistory.length, greaterThanOrEqualTo(4));
    for (var i = 1; i < demo.growthHistory.length; i++) {
      expect(
        demo.growthHistory[i].recordedAt.isBefore(
          demo.growthHistory[i - 1].recordedAt,
        ),
        isFalse,
      );
    }
    expect(
      GrowthEstimator.estimate(demo.growthHistory.last.measurement),
      GrowthStatus.healthyRange,
    );
  });

  test('every seeded demo vaccine id exists in the current schedule', () {
    final demo = buildDemoProfile(now: DateTime(2026, 8, 31, 12));
    final validIds = vaccineSchedule
        .expand((milestone) => milestone.vaccines)
        .map((vaccine) => vaccine.id)
        .toSet();

    expect(demo.vaccineRecords, isNotEmpty);
    expect(demo.vaccineRecords.keys.every(validIds.contains), isTrue);
  });
}
