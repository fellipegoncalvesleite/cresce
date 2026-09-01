import 'age_range.dart';

/// Short, supportive local guidance appropriate to an age range.
class BabyTip {
  const BabyTip({
    required this.id,
    required this.text,
    required this.ageRange,
    this.category,
  });

  final String id;
  final String text;
  final AgeRange ageRange;
  final String? category;
}
