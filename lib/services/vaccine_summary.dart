import '../models/vaccine.dart';

class VaccineProgressSummary {
  const VaccineProgressSummary({
    required this.dueTotal,
    required this.takenDue,
    required this.overdue,
    required this.upcoming,
    required this.ageKnown,
  });

  final int dueTotal;
  final int takenDue;
  final int overdue;
  final int upcoming;
  final bool ageKnown;

  double? get completion {
    if (!ageKnown || dueTotal == 0) return null;
    return takenDue / dueTotal;
  }
}

class VaccineNextMilestone {
  const VaccineNextMilestone({
    required this.ageInMonths,
    required this.ageLabel,
    required this.vaccines,
    required this.isOverdue,
  });

  final int ageInMonths;
  final String ageLabel;
  final List<VaccineInfo> vaccines;
  final bool isOverdue;
}

VaccineProgressSummary calculateVaccineProgressSummary({
  required List<VaccineScheduleItem> schedule,
  required int? babyAgeMonths,
  required VaccineRecord? Function(String vaccineId) recordFor,
}) {
  if (babyAgeMonths == null) {
    return const VaccineProgressSummary(
      dueTotal: 0,
      takenDue: 0,
      overdue: 0,
      upcoming: 0,
      ageKnown: false,
    );
  }

  var dueTotal = 0;
  var takenDue = 0;
  var overdue = 0;

  for (final item in schedule) {
    final months = item.ageInMonths;
    if (months == null || months > babyAgeMonths) continue;

    for (final vaccine in item.vaccines) {
      dueTotal++;
      if (recordFor(vaccine.id)?.taken ?? false) {
        takenDue++;
      } else {
        overdue++;
      }
    }
  }

  final upcomingMilestone = _nearestFutureMilestone(
    schedule: schedule,
    babyAgeMonths: babyAgeMonths,
    recordFor: recordFor,
  );

  return VaccineProgressSummary(
    dueTotal: dueTotal,
    takenDue: takenDue,
    overdue: overdue,
    upcoming: upcomingMilestone?.vaccines.length ?? 0,
    ageKnown: true,
  );
}

VaccineNextMilestone? nextRelevantVaccineMilestone({
  required List<VaccineScheduleItem> schedule,
  required int? babyAgeMonths,
  required VaccineRecord? Function(String vaccineId) recordFor,
}) {
  if (babyAgeMonths == null) return null;

  final fixedItems = _sortedFixedItems(schedule);

  for (final item in fixedItems) {
    final months = item.ageInMonths!;
    if (months > babyAgeMonths) break;
    if (_hasMissingVaccines(item, recordFor)) {
      return _buildMilestone(
        items: fixedItems,
        ageInMonths: months,
        recordFor: recordFor,
        isOverdue: true,
      );
    }
  }

  return _nearestFutureMilestone(
    schedule: fixedItems,
    babyAgeMonths: babyAgeMonths,
    recordFor: recordFor,
  );
}

VaccineNextMilestone? _nearestFutureMilestone({
  required List<VaccineScheduleItem> schedule,
  required int babyAgeMonths,
  required VaccineRecord? Function(String vaccineId) recordFor,
}) {
  final fixedItems = _sortedFixedItems(schedule);

  for (final item in fixedItems) {
    final months = item.ageInMonths!;
    if (months <= babyAgeMonths) continue;
    if (_hasMissingVaccines(item, recordFor)) {
      return _buildMilestone(
        items: fixedItems,
        ageInMonths: months,
        recordFor: recordFor,
        isOverdue: false,
      );
    }
  }

  return null;
}

List<VaccineScheduleItem> _sortedFixedItems(
  List<VaccineScheduleItem> schedule,
) =>
    schedule.where((item) => item.ageInMonths != null).toList()
      ..sort((a, b) => a.ageInMonths!.compareTo(b.ageInMonths!));

bool _hasMissingVaccines(
  VaccineScheduleItem item,
  VaccineRecord? Function(String vaccineId) recordFor,
) => item.vaccines.any((vaccine) => !(recordFor(vaccine.id)?.taken ?? false));

VaccineNextMilestone _buildMilestone({
  required List<VaccineScheduleItem> items,
  required int ageInMonths,
  required VaccineRecord? Function(String vaccineId) recordFor,
  required bool isOverdue,
}) {
  final matchingItems = items
      .where((item) => item.ageInMonths == ageInMonths)
      .toList(growable: false);
  final missing = matchingItems
      .expand((item) => item.vaccines)
      .where((vaccine) => !(recordFor(vaccine.id)?.taken ?? false))
      .toList(growable: false);

  return VaccineNextMilestone(
    ageInMonths: ageInMonths,
    ageLabel: matchingItems.first.ageLabel,
    vaccines: missing,
    isOverdue: isOverdue,
  );
}
