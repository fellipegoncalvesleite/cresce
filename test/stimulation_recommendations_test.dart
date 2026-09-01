import 'dart:io';

import 'package:bebecare/data/baby_activities.dart';
import 'package:bebecare/data/media_data.dart';
import 'package:bebecare/models/age_range.dart';
import 'package:bebecare/services/stimulation_recommendations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('story age applicability is machine-readable', () {
    expect(stories, isNotEmpty);
    expect(
      stories.map((story) => story.ageRange),
      everyElement(isA<AgeRange>()),
    );
    expect(stories.every((story) => story.ageLabel.isNotEmpty), isTrue);
  });

  test('song age applicability is machine-readable', () {
    expect(songs, isNotEmpty);
    expect(songs.map((song) => song.ageRange), everyElement(isA<AgeRange>()));
  });

  test('animal sound age applicability is machine-readable', () {
    expect(animalSounds, isNotEmpty);
    expect(
      animalSounds.map((sound) => sound.ageRange),
      everyElement(isA<AgeRange>()),
    );
  });

  test('activitiesForAge returns only activities suitable for that age', () {
    final activities = activitiesForAge(8);

    expect(activities, isNotEmpty);
    expect(
      activities.every((activity) => activity.ageRange.contains(8)),
      isTrue,
    );
  });

  test('activity age boundaries are inclusive', () {
    final atSix = activitiesForAge(6).map((activity) => activity.id).toSet();
    final atEighteen = activitiesForAge(
      18,
    ).map((activity) => activity.id).toSet();

    expect(atSix, contains('peekaboo_together'));
    expect(atEighteen, contains('peekaboo_together'));
  });

  test('unknown age returns safe non-empty recommendations', () {
    expect(activitiesForAge(null), isNotEmpty);
    expect(storiesForAge(null), isNotEmpty);
    expect(songsForAge(null), isNotEmpty);
    expect(soundsForAge(null), isNotEmpty);

    final daily = recommendationsForDay(
      date: DateTime(2026, 9, 1),
      ageMonths: null,
    );
    expect(daily.activity, isNotNull);
    expect(daily.story, isNotNull);
    expect(daily.song, isNotNull);
    expect(daily.sound, isNotNull);
  });

  test('daily recommendations are deterministic for same date and age', () {
    final date = DateTime(2026, 9, 1, 23, 59);

    final first = recommendationsForDay(date: date, ageMonths: 8);
    final second = recommendationsForDay(date: date, ageMonths: 8);

    expect(second.activity.id, first.activity.id);
    expect(second.story?.id, first.story?.id);
    expect(second.song?.title, first.song?.title);
    expect(second.sound?.name, first.sound?.name);
  });

  test('Lia at eight months receives a complete age-appropriate set', () {
    final daily = recommendationsForDay(
      date: DateTime(2026, 9, 1),
      ageMonths: 8,
    );

    expect(daily.activity.ageRange.contains(8), isTrue);
    expect(daily.story, isNotNull);
    expect(daily.story!.ageRange.contains(8), isTrue);
    expect(daily.song, isNotNull);
    expect(daily.song!.ageRange.contains(8), isTrue);
    expect(daily.sound, isNotNull);
    expect(daily.sound!.ageRange.contains(8), isTrue);
    expect(
      activitiesForAge(8).map((activity) => activity.id),
      contains('peekaboo_together'),
    );
  });

  test('curated activities cover the full 0 to 48 month span', () {
    expect(babyActivities.length, inInclusiveRange(20, 30));
    for (var month = 0; month <= 48; month++) {
      expect(
        activitiesForAge(month),
        isNotEmpty,
        reason: 'month $month should have at least one activity',
      );
    }
  });

  test('all primary animal sounds are real bundled assets', () {
    expect(animalSounds.length, inInclusiveRange(6, 8));
    expect(animalSounds.every((sound) => sound.hasAudio), isTrue);

    for (final sound in animalSounds) {
      expect(sound.assetPath, isNotNull);
      expect(
        File('assets/${sound.assetPath}').existsSync(),
        isTrue,
        reason: '${sound.name} should point to an existing bundled asset',
      );
      expect(sound.sourceUrl, startsWith('https://'));
      expect(sound.license, isNotEmpty);
      expect(sound.licenseUrl, startsWith('https://'));
    }
  });

  test('exactly three curated activities open mini experiences', () {
    final interactive = babyActivities
        .where((activity) => activity.experience != null)
        .toList();

    expect(interactive, hasLength(3));
  });
}
