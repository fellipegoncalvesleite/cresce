import 'age_range.dart';

enum BabyActivityCategory { movement, language, sensory, social, calm, play }

enum BabyActivityExperience { peekaboo, animalSounds, shapes }

class BabyActivity {
  const BabyActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.ageRange,
    required this.category,
    required this.durationMinutes,
    required this.instructions,
    this.experience,
  });

  final String id;
  final String title;
  final String description;
  final AgeRange ageRange;
  final BabyActivityCategory category;
  final int durationMinutes;
  final List<String> instructions;
  final BabyActivityExperience? experience;

  bool get isInteractive => experience != null;
}
