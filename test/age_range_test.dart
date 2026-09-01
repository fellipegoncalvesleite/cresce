import 'package:bebecare/models/age_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AgeRange includes both boundaries', () {
    const range = AgeRange(minMonths: 3, maxMonths: 6);

    expect(range.contains(3), isTrue);
    expect(range.contains(6), isTrue);
    expect(range.contains(2), isFalse);
    expect(range.contains(7), isFalse);
  });

  test('AgeRange rejects a negative minimum', () {
    expect(
      () => AgeRange(minMonths: -1, maxMonths: 3),
      throwsA(isA<AssertionError>()),
    );
  });

  test('AgeRange rejects max below min', () {
    expect(
      () => AgeRange(minMonths: 6, maxMonths: 3),
      throwsA(isA<AssertionError>()),
    );
  });
}
