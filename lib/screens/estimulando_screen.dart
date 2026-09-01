import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/baby_activities.dart';
import '../data/media_data.dart';
import '../models/baby_activity.dart';
import '../models/media.dart';
import '../services/app_state.dart';
import '../services/external_search.dart';
import '../services/sound_player.dart';
import '../services/stimulation_recommendations.dart';
import '../theme/app_tokens.dart';
import '../widgets/animal_sound_card.dart';
import '../widgets/app_card.dart';
import '../widgets/disclaimer_note.dart';
import '../widgets/song_card.dart';
import '../widgets/story_card.dart';
import 'animal_sound_game_screen.dart';
import 'peekaboo_activity_screen.dart';
import 'shapes_activity_screen.dart';
import 'story_reader_screen.dart';

class EstimulandoScreen extends StatelessWidget {
  const EstimulandoScreen({super.key, this.referenceDate, this.soundPlayer});

  final DateTime? referenceDate;
  final SoundPlaybackController? soundPlayer;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final age = state.babyAgeMonths;
    final date = referenceDate ?? DateTime.now();
    final daily = recommendationsForDay(date: date, ageMonths: age);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Estímulos'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Para hoje'),
              Tab(text: 'Brincadeiras'),
              Tab(text: 'Sons'),
              Tab(text: 'Histórias'),
              Tab(text: 'Cantigas'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _TodayTab(
                babyName: state.babyName,
                ageMonths: age,
                daily: daily,
                player: soundPlayer,
              ),
              _ActivitiesTab(ageMonths: age, player: soundPlayer),
              _SoundsTab(ageMonths: age, player: soundPlayer),
              _StoriesTab(ageMonths: age),
              _SongsTab(ageMonths: age),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  const _TodayTab({
    required this.babyName,
    required this.ageMonths,
    required this.daily,
    this.player,
  });

  final String babyName;
  final int? ageMonths;
  final DailyStimulationRecommendations daily;
  final SoundPlaybackController? player;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('stimulation-Para hoje'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ageMonths == null
                ? 'Ideias para hoje'
                : 'Para $babyName · $ageMonths meses',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ageMonths == null
                ? 'Adicione a data de nascimento para deixar as ideias mais específicas para esta fase.'
                : 'Ideias para esta fase, sem pressa e sem transformar brincadeira em tarefa.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.inkMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionTitle('Atividade de hoje'),
          const SizedBox(height: AppSpacing.sm),
          _ActivityCard(activity: daily.activity, player: player),
          if (daily.story != null) ...[
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('História para hoje'),
            const SizedBox(height: AppSpacing.sm),
            StoryCard(
              story: daily.story!,
              onRead: () => _openStory(context, daily.story!),
            ),
          ],
          if (daily.sound != null) ...[
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('Som para explorar'),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 220,
              child: AnimalSoundCard(sound: daily.sound!, player: player),
            ),
          ],
          if (daily.song != null) ...[
            const SizedBox(height: AppSpacing.xl),
            const _SectionTitle('Cantiga para hoje'),
            const SizedBox(height: AppSpacing.sm),
            SongCard(song: daily.song!),
          ],
          const SizedBox(height: AppSpacing.xl),
          const DisclaimerNote(
            icon: Icons.favorite_outline,
            text:
                'Para bebês, prefira brincadeiras curtas e acompanhadas. Muitas ideias podem ser feitas fora da tela.',
          ),
        ],
      ),
    );
  }
}

class _ActivitiesTab extends StatelessWidget {
  const _ActivitiesTab({required this.ageMonths, this.player});

  final int? ageMonths;
  final SoundPlaybackController? player;

  @override
  Widget build(BuildContext context) {
    final suitable = activitiesForAge(ageMonths);
    final suitableIds = suitable.map((activity) => activity.id).toSet();
    final others = babyActivities
        .where((activity) => !suitableIds.contains(activity.id))
        .toList();

    return ListView(
      key: const Key('stimulation-Brincadeiras'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          ageMonths == null
              ? 'Ideias para brincar juntos'
              : 'Ideias para esta fase',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Atividades de vida real aparecem primeiro. As experiências na tela são curtas e para fazer acompanhado.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.inkMuted,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final activity in suitable) ...[
          _ActivityCard(activity: activity, player: player),
          const SizedBox(height: AppSpacing.md),
        ],
        if (others.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Explorar outras ideias',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final activity in others) ...[
            _ActivityCard(activity: activity, player: player),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, this.player});

  final BabyActivity activity;
  final SoundPlaybackController? player;

  @override
  Widget build(BuildContext context) {
    final interactive = activity.isInteractive;
    return AppCard(
      semanticLabel: activity.title,
      onTap: () => interactive
          ? _openExperience(context, activity.experience!, player)
          : _showActivityDetails(context, activity),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SmallChip(
                icon: interactive
                    ? Icons.touch_app_outlined
                    : Icons.people_outline,
                label: interactive ? 'Na tela · juntos' : 'Fora da tela',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            activity.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.inkMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _SmallChip(
                icon: Icons.child_care_outlined,
                label:
                    '${activity.ageRange.minMonths}–${activity.ageRange.maxMonths} meses',
              ),
              _SmallChip(
                icon: Icons.schedule_outlined,
                label: '${activity.durationMinutes} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoundsTab extends StatelessWidget {
  const _SoundsTab({required this.ageMonths, this.player});

  final int? ageMonths;
  final SoundPlaybackController? player;

  @override
  Widget build(BuildContext context) {
    final ordered = _ageFirst(
      animalSounds,
      soundsForAge(ageMonths),
      (sound) => sound.id,
    );
    return GridView.count(
      key: const Key('stimulation-Sons'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.82,
      children: [
        for (final sound in ordered)
          AnimalSoundCard(sound: sound, player: player),
      ],
    );
  }
}

class _StoriesTab extends StatelessWidget {
  const _StoriesTab({required this.ageMonths});

  final int? ageMonths;

  @override
  Widget build(BuildContext context) {
    final ordered = _ageFirst(
      stories,
      storiesForAge(ageMonths),
      (story) => story.id,
    );
    return ListView(
      key: const Key('stimulation-Histórias'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        for (final story in ordered) ...[
          StoryCard(story: story, onRead: () => _openStory(context, story)),
          const SizedBox(height: AppSpacing.md),
        ],
        const DisclaimerNote(
          icon: Icons.auto_stories_outlined,
          text:
              'Histórias originais do Cresce ou de domínio público. Não reproduzimos livros protegidos por direitos autorais.',
        ),
      ],
    );
  }
}

class _SongsTab extends StatelessWidget {
  const _SongsTab({required this.ageMonths});

  final int? ageMonths;

  @override
  Widget build(BuildContext context) {
    final ordered = _ageFirst(
      songs,
      songsForAge(ageMonths),
      (song) => song.title,
    );
    return ListView(
      key: const Key('stimulation-Cantigas'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        for (final song in ordered) ...[
          SongCard(song: song),
          const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ouvir e assistir mais',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final rec in externalRecommendations) ...[
          _ExternalRecCard(rec: rec),
          const SizedBox(height: AppSpacing.md),
        ],
        const DisclaimerNote(
          icon: Icons.visibility_outlined,
          text:
              'Confira sempre o conteúdo antes de deixar a criança assistir ou ouvir. Evite telas por longos períodos e prefira áudio calmo.',
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
  );
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.inkMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openStory(BuildContext context, Story story) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => StoryReaderScreen(story: story)),
  );
}

Future<void> _openExperience(
  BuildContext context,
  BabyActivityExperience experience,
  SoundPlaybackController? player,
) async {
  final screen = switch (experience) {
    BabyActivityExperience.peekaboo => const PeekabooActivityScreen(),
    BabyActivityExperience.animalSounds => AnimalSoundGameScreen(
      player: player,
    ),
    BabyActivityExperience.shapes => const ShapesActivityScreen(),
  };
  await Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));
}

Future<void> _showActivityDetails(
  BuildContext context,
  BabyActivity activity,
) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              activity.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < activity.instructions.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}.',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(activity.instructions[i])),
                ],
              ),
              if (i != activity.instructions.length - 1)
                const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    ),
  );
}

List<T> _ageFirst<T>(
  List<T> all,
  List<T> suitable,
  String Function(T item) idOf,
) {
  final suitableIds = suitable.map(idOf).toSet();
  return [
    ...suitable,
    ...all.where((item) => !suitableIds.contains(idOf(item))),
  ];
}

class _ExternalRecCard extends StatelessWidget {
  const _ExternalRecCard({required this.rec});

  final ExternalMediaLink rec;

  static const _search = ExternalSearch();

  Future<void> _open(BuildContext context, MediaPlatform platform) async {
    final uri = switch (platform) {
      MediaPlatform.youtube => _search.youtubeSearch(rec.query),
      MediaPlatform.spotify => _search.spotifySearch(rec.query),
    };
    final ok = await _search.open(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o ${platform.label}.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec.label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rec.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.inkMuted,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _open(context, MediaPlatform.youtube),
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('YouTube'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _open(context, MediaPlatform.spotify),
                  icon: const Icon(Icons.headphones_outlined, size: 18),
                  label: const Text('Spotify'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
