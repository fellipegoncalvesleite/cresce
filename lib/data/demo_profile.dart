import '../models/growth.dart';
import '../models/vaccine.dart';

class DemoProfileData {
  const DemoProfileData({
    required this.babyName,
    required this.birthDate,
    required this.parent1Name,
    required this.parent2Name,
    required this.email,
    required this.growthHistory,
    required this.vaccineRecords,
  });

  final String babyName;
  final DateTime birthDate;
  final String parent1Name;
  final String parent2Name;
  final String email;
  final List<GrowthRecord> growthHistory;
  final Map<String, VaccineRecord> vaccineRecords;
}

/// Subtracts calendar months while preserving local time and clamping the day
/// to the last valid day of the target month.
DateTime subtractCalendarMonths(DateTime date, int months) {
  assert(months >= 0);
  final totalMonths = date.year * 12 + date.month - 1 - months;
  final year = totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day <= lastDay ? date.day : lastDay;
  return DateTime(
    year,
    month,
    day,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}

DateTime _addCalendarMonths(DateTime date, int months) {
  assert(months >= 0);
  final totalMonths = date.year * 12 + date.month - 1 + months;
  final year = totalMonths ~/ 12;
  final month = totalMonths % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = date.day <= lastDay ? date.day : lastDay;
  return DateTime(
    year,
    month,
    day,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}

int wholeMonthsBetween(DateTime earlier, DateTime later) {
  var months = (later.year - earlier.year) * 12 + later.month - earlier.month;
  if (later.day < earlier.day) months -= 1;
  return months < 0 ? 0 : months;
}

DemoProfileData buildDemoProfile({DateTime? now}) {
  final current = now ?? DateTime.now();
  final birthDate = subtractCalendarMonths(current, 8);

  final growthHistory = <GrowthRecord>[
    GrowthRecord(
      measurement: const GrowthMeasurement(
        weightKg: 5.4,
        lengthCm: 58,
        ageMonths: 2,
      ),
      recordedAt: _addCalendarMonths(birthDate, 2),
    ),
    GrowthRecord(
      measurement: const GrowthMeasurement(
        weightKg: 6.4,
        lengthCm: 63,
        ageMonths: 4,
      ),
      recordedAt: _addCalendarMonths(birthDate, 4),
    ),
    GrowthRecord(
      measurement: const GrowthMeasurement(
        weightKg: 7.2,
        lengthCm: 67,
        ageMonths: 6,
      ),
      recordedAt: _addCalendarMonths(birthDate, 6),
    ),
    GrowthRecord(
      measurement: const GrowthMeasurement(
        weightKg: 8.0,
        lengthCm: 70,
        ageMonths: 8,
      ),
      recordedAt: _addCalendarMonths(birthDate, 8),
    ),
  ];

  VaccineRecord takenAtMonth(int months) => VaccineRecord(
    taken: true,
    takenDate: _addCalendarMonths(birthDate, months),
  );

  final vaccineRecords = <String, VaccineRecord>{
    'bcg_0': takenAtMonth(0),
    'hepb_0': takenAtMonth(0),
    'penta_2': takenAtMonth(2),
    'vip_2': takenAtMonth(2),
    'pneumo_2': takenAtMonth(2),
    'rota_2': takenAtMonth(2),
    'menc_3': takenAtMonth(3),
    'penta_4': takenAtMonth(4),
    'vip_4': takenAtMonth(4),
    'pneumo_4': takenAtMonth(4),
    'rota_4': takenAtMonth(4),
    'menc_5': takenAtMonth(5),
    'penta_6': takenAtMonth(6),
    'vip_6': takenAtMonth(6),
  };

  return DemoProfileData(
    babyName: 'Lia',
    birthDate: birthDate,
    parent1Name: 'Marina',
    parent2Name: 'Rafael',
    email: 'familia.lia@exemplo.com',
    growthHistory: growthHistory,
    vaccineRecords: vaccineRecords,
  );
}
