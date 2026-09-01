import 'age_range.dart';

/// Short personality copy for Home. This is not developmental advice.
class BabyMessage {
  const BabyMessage({required this.id, required this.text, this.ageRange});

  final String id;
  final String text;
  final AgeRange? ageRange;
}
