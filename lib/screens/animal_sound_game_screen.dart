import 'package:flutter/material.dart';

import '../data/media_data.dart';
import '../models/media.dart';
import '../services/sound_player.dart';
import '../theme/app_tokens.dart';

class AnimalSoundGameScreen extends StatelessWidget {
  const AnimalSoundGameScreen({
    super.key,
    this.player,
    this.sounds = animalSounds,
  });

  final SoundPlaybackController? player;
  final List<AnimalSound> sounds;

  SoundPlaybackController get _player => player ?? SoundPlayer.instance;

  Future<void> _play(BuildContext context, AnimalSound sound) async {
    final path = sound.assetPath;
    if (path == null) return;
    try {
      await _player.toggle(path);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível tocar o som.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final choices = sounds.where((sound) => sound.hasAudio).take(4).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Toque no bichinho')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Text(
                'Escolham um animal, ouçam uma vez e tentem imitar o som juntos.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ValueListenableBuilder<String?>(
                  valueListenable: _player.playing,
                  builder: (context, playingPath, _) {
                    return GridView.builder(
                      itemCount: choices.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisExtent: 190,
                            mainAxisSpacing: AppSpacing.md,
                            crossAxisSpacing: AppSpacing.md,
                          ),
                      itemBuilder: (context, index) {
                        final sound = choices[index];
                        return Semantics(
                          button: true,
                          label: playingPath == sound.assetPath
                              ? 'Parar som de ${sound.name}. Ouvindo ${sound.name}'
                              : 'Tocar som de ${sound.name}',
                          child: Material(
                            color: playingPath == sound.assetPath
                                ? AppColors.accentSoft
                                : AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.cardRadius,
                            ),
                            child: InkWell(
                              key: Key('animal-game-${sound.id}'),
                              borderRadius: AppRadii.cardRadius,
                              onTap: () => _play(context, sound),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      sound.emoji,
                                      style: const TextStyle(fontSize: 52),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      sound.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          playingPath == sound.assetPath
                                              ? Icons.graphic_eq_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 18,
                                          color: AppColors.inkMuted,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Flexible(
                                          child: Text(
                                            playingPath == sound.assetPath
                                                ? 'Ouvindo ${sound.name}'
                                                : 'Tocar',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.inkMuted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
