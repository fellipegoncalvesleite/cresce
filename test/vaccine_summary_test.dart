import 'package:bebecare/data/vaccine_schedule.dart';
import 'package:bebecare/models/vaccine.dart';
import 'package:bebecare/services/vaccine_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  VaccineRecord? none(String _) => null;

  VaccineProgressSummary summaryFor(
    int? age, {
    Set<String> takenIds = const {},
  }) {
    return calculateVaccineProgressSummary(
      schedule: vaccineSchedule,
      babyAgeMonths: age,
      recordFor: (id) =>
          takenIds.contains(id) ? const VaccineRecord(taken: true) : null,
    );
  }

  test('unknown baby age produces no completion percentage', () {
    final summary = calculateVaccineProgressSummary(
      schedule: vaccineSchedule,
      babyAgeMonths: null,
      recordFor: none,
    );

    expect(summary.completion, isNull);
    expect(summary.ageKnown, isFalse);
  });

  test('8-month-old denominator contains only milestones through 8 months', () {
    final summary = summaryFor(8);

    expect(summary.dueTotal, 16);
  });

  test('future 9/12/15/48-month vaccines are excluded from due progress', () {
    final futureIds = vaccineSchedule
        .where((item) => (item.ageInMonths ?? -1) > 8)
        .expand((item) => item.vaccines)
        .map((vaccine) => vaccine.id)
        .toSet();
    final summary = summaryFor(8, takenIds: futureIds);

    expect(summary.dueTotal, 16);
    expect(summary.takenDue, 0);
    expect(summary.completion, 0);
  });

  test('taken due vaccines increment completion correctly', () {
    final dueIds = vaccineSchedule
        .where((item) => (item.ageInMonths ?? 999) <= 8)
        .expand((item) => item.vaccines)
        .map((vaccine) => vaccine.id)
        .toList();
    final summary = summaryFor(8, takenIds: dueIds.take(8).toSet());

    expect(summary.takenDue, 8);
    expect(summary.completion, 0.5);
  });

  test('untaken due vaccines are counted as overdue', () {
    final summary = summaryFor(8);

    expect(summary.overdue, 16);
  });

  test('future vaccines do not lower completion percentage', () {
    final dueIds = vaccineSchedule
        .where((item) => (item.ageInMonths ?? 999) <= 8)
        .expand((item) => item.vaccines)
        .map((vaccine) => vaccine.id)
        .toSet();
    final summary = summaryFor(8, takenIds: dueIds);

    expect(summary.takenDue, 16);
    expect(summary.dueTotal, 16);
    expect(summary.completion, 1);
  });

  test('next relevant milestone prioritizes oldest overdue vaccines', () {
    final next = nextRelevantVaccineMilestone(
      schedule: vaccineSchedule,
      babyAgeMonths: 8,
      recordFor: none,
    );

    expect(next, isNotNull);
    expect(next!.ageInMonths, 0);
    expect(next.isOverdue, isTrue);
    expect(next.vaccines, hasLength(2));
  });

  test('when no overdue remain next relevant milestone is nearest future', () {
    final dueIds = vaccineSchedule
        .where((item) => (item.ageInMonths ?? 999) <= 8)
        .expand((item) => item.vaccines)
        .map((vaccine) => vaccine.id)
        .toSet();

    final next = nextRelevantVaccineMilestone(
      schedule: vaccineSchedule,
      babyAgeMonths: 8,
      recordFor: (id) =>
          dueIds.contains(id) ? const VaccineRecord(taken: true) : null,
    );

    expect(next, isNotNull);
    expect(next!.ageInMonths, 9);
    expect(next.isOverdue, isFalse);
  });

  test('multiple vaccines at the next milestone are grouped together', () {
    final dueIds = vaccineSchedule
        .where((item) => (item.ageInMonths ?? 999) <= 8)
        .expand((item) => item.vaccines)
        .map((vaccine) => vaccine.id)
        .toSet();

    final next = nextRelevantVaccineMilestone(
      schedule: vaccineSchedule,
      babyAgeMonths: 8,
      recordFor: (id) =>
          dueIds.contains(id) ? const VaccineRecord(taken: true) : null,
    );

    expect(next!.ageInMonths, 9);
    expect(next.vaccines.map((vaccine) => vaccine.id), {
      'febreamarela_9',
      'covid_9',
    });
    expect(summaryFor(8, takenIds: dueIds).upcoming, 2);
  });

  test('separate schedule items at the same month are grouped together', () {
    const first = VaccineInfo(
      id: 'same_month_a',
      name: 'Vacina A',
      dose: 'Dose única',
      protectsAgainst: 'A',
      notes: 'Teste',
    );
    const second = VaccineInfo(
      id: 'same_month_b',
      name: 'Vacina B',
      dose: 'Dose única',
      protectsAgainst: 'B',
      notes: 'Teste',
    );
    const schedule = <VaccineScheduleItem>[
      VaccineScheduleItem(
        ageLabel: '9 meses',
        ageInMonths: 9,
        vaccines: [first],
      ),
      VaccineScheduleItem(
        ageLabel: '9 meses',
        ageInMonths: 9,
        vaccines: [second],
      ),
    ];

    final summary = calculateVaccineProgressSummary(
      schedule: schedule,
      babyAgeMonths: 8,
      recordFor: none,
    );
    final next = nextRelevantVaccineMilestone(
      schedule: schedule,
      babyAgeMonths: 8,
      recordFor: none,
    );

    expect(summary.upcoming, 2);
    expect(next, isNotNull);
    expect(next!.vaccines.map((vaccine) => vaccine.id), {
      'same_month_a',
      'same_month_b',
    });
  });

  test('fully complete represented schedule returns no next item', () {
    final allIds = vaccineSchedule
        .expand((item) => item.vaccines)
        .map((vaccine) => vaccine.id)
        .toSet();

    final next = nextRelevantVaccineMilestone(
      schedule: vaccineSchedule,
      babyAgeMonths: 48,
      recordFor: (id) =>
          allIds.contains(id) ? const VaccineRecord(taken: true) : null,
    );

    expect(next, isNull);
  });
}
