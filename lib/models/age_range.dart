/// Inclusive calendar-age range expressed in whole months.
class AgeRange {
  const AgeRange({required this.minMonths, required this.maxMonths})
    : assert(minMonths >= 0),
      assert(maxMonths >= minMonths);

  final int minMonths;
  final int maxMonths;

  bool contains(int months) => months >= minMonths && months <= maxMonths;
}
