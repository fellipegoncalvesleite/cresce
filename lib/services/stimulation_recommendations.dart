import '../data/baby_activities.dart';
import '../data/media_data.dart';
import '../models/baby_activity.dart';
import '../models/media.dart';

class DailyStimulationRecommendations {
  const DailyStimulationRecommendations({
    required this.activity,
    this.story,
    this.song,
    this.sound,
  });

  final BabyActivity activity;
  final Story? story;
  final Song? song;
  final AnimalSound? sound;
}

List<BabyActivity> activitiesForAge(int? ageMonths) {
  if (ageMonths == null) return List.unmodifiable(genericBabyActivities);
  final matches = babyActivities
      .where((activity) => activity.ageRange.contains(ageMonths))
      .toList(growable: false);
  return matches.isEmpty ? List.unmodifiable(genericBabyActivities) : matches;
}

List<Story> storiesForAge(int? ageMonths) =>
    _forAge(stories, ageMonths, (story) => story.ageRange.contains(ageMonths!));

List<Song> songsForAge(int? ageMonths) =>
    _forAge(songs, ageMonths, (song) => song.ageRange.contains(ageMonths!));

List<AnimalSound> soundsForAge(int? ageMonths) => _forAge(
  animalSounds,
  ageMonths,
  (sound) => sound.ageRange.contains(ageMonths!),
);

DailyStimulationRecommendations recommendationsForDay({
  required DateTime date,
  int? ageMonths,
}) {
  final activities = activitiesForAge(ageMonths);
  final suitableStories = storiesForAge(ageMonths);
  final suitableSongs = songsForAge(ageMonths);
  final suitableSounds = soundsForAge(ageMonths);
  final seed =
      date.year * 10000 + date.month * 100 + date.day + (ageMonths ?? 0) * 37;

  return DailyStimulationRecommendations(
    activity: activities[_index(seed, 11, activities.length)],
    story: _pick(suitableStories, seed, 23),
    song: _pick(suitableSongs, seed, 41),
    sound: _pick(suitableSounds, seed, 59),
  );
}

List<T> _forAge<T>(
  List<T> source,
  int? ageMonths,
  bool Function(T item) isSuitable,
) {
  if (source.isEmpty) return const [];
  if (ageMonths == null) return List.unmodifiable(source);
  final matches = source.where(isSuitable).toList(growable: false);
  return matches.isEmpty ? List.unmodifiable(source) : matches;
}

T? _pick<T>(List<T> items, int seed, int salt) =>
    items.isEmpty ? null : items[_index(seed, salt, items.length)];

int _index(int seed, int salt, int length) => (seed * salt).abs() % length;
