import 'package:bebecare/models/growth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GrowthRecord serializes and deserializes', () {
    final recordedAt = DateTime(2026, 8, 31, 14, 30);
    final record = GrowthRecord(
      measurement: const GrowthMeasurement(
        weightKg: 8.1,
        lengthCm: 70.5,
        ageMonths: 8,
      ),
      recordedAt: recordedAt,
    );

    final decoded = GrowthRecord.fromJson(record.toJson());

    expect(decoded, isNotNull);
    expect(decoded!.measurement.weightKg, 8.1);
    expect(decoded.measurement.lengthCm, 70.5);
    expect(decoded.measurement.ageMonths, 8);
    expect(decoded.recordedAt, recordedAt);
  });

  test('GrowthRecord rejects malformed persisted data', () {
    expect(GrowthRecord.fromJson({'recordedAt': 'not-a-date'}), isNull);
    expect(
      GrowthRecord.fromJson({
        'recordedAt': DateTime(2026, 8, 31).toIso8601String(),
        'measurement': {'weightKg': 'bad', 'lengthCm': 70},
      }),
      isNull,
    );
  });
}
