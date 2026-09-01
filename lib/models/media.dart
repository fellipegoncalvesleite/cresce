import 'package:flutter/material.dart';

import 'age_range.dart';

/// A bundled animal sound with structured age guidance and provenance.
class AnimalSound {
  const AnimalSound({
    required this.id,
    required this.name,
    required this.emoji,
    required this.ageRange,
    required this.source,
    required this.sourceUrl,
    required this.author,
    required this.license,
    required this.licenseUrl,
    required this.attributionRequired,
    required this.modification,
    this.assetPath,
  });

  final String id;
  final String name;
  final String emoji;
  final AgeRange ageRange;
  final String? assetPath;
  final String source;
  final String sourceUrl;
  final String author;
  final String license;
  final String licenseUrl;
  final bool attributionRequired;
  final String modification;

  bool get hasAudio => assetPath != null;

  String get ageLabel => _ageLabel(ageRange);
}

/// A short story shown in the reader. Either an original Cresce story or a
/// public-domain text — never a copyrighted children's book.
class Story {
  const Story({
    required this.id,
    required this.title,
    required this.ageRange,
    required this.readingMinutes,
    required this.paragraphs,
    required this.origin,
  });

  final String id;
  final String title;
  final AgeRange ageRange;
  final int readingMinutes;
  final List<String> paragraphs;

  /// e.g. "História original Cresce" or "Domínio público".
  final String origin;

  String get ageLabel => _ageLabel(ageRange);
}

/// What moment a song suits, used to label cards (never the full lyrics).
enum SongMoment { sleep, play, bath, calm }

extension SongMomentX on SongMoment {
  String get label => switch (this) {
    SongMoment.sleep => 'Dormir',
    SongMoment.play => 'Brincar',
    SongMoment.bath => 'Banho',
    SongMoment.calm => 'Acalmar',
  };

  IconData get icon => switch (this) {
    SongMoment.sleep => Icons.bedtime_outlined,
    SongMoment.play => Icons.toys_outlined,
    SongMoment.bath => Icons.bubble_chart_outlined,
    SongMoment.calm => Icons.spa_outlined,
  };
}

/// A traditional/public-domain song. We store a title + suggested use + a
/// search query to open on an external platform — never copyrighted lyrics.
class Song {
  const Song({
    required this.title,
    required this.moment,
    required this.suggestion,
    required this.searchQuery,
    required this.ageRange,
    this.isPublicDomain = true,
  });

  final String title;
  final SongMoment moment;
  final String suggestion;
  final String searchQuery;
  final AgeRange ageRange;
  final bool isPublicDomain;

  String get ageLabel => _ageLabel(ageRange);
}

enum MediaPlatform { youtube, spotify }

extension MediaPlatformX on MediaPlatform {
  String get label => switch (this) {
    MediaPlatform.youtube => 'YouTube',
    MediaPlatform.spotify => 'Spotify',
  };

  IconData get icon => switch (this) {
    MediaPlatform.youtube => Icons.play_circle_outline,
    MediaPlatform.spotify => Icons.headphones_outlined,
  };
}

/// An external recommendation that opens a search on a platform.
class ExternalMediaLink {
  const ExternalMediaLink({
    required this.label,
    required this.query,
    required this.description,
  });

  final String label;
  final String query;
  final String description;
}

String _ageLabel(AgeRange range) =>
    '${range.minMonths}–${range.maxMonths} meses';
