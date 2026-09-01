import 'package:flutter/material.dart';

import '../models/media.dart';
import '../services/sound_player.dart';
import '../theme/app_tokens.dart';

/// Calm sound tile backed by the existing licensed clip and shared player.
/// Playback/provenance behavior remains unchanged and there is no autoplay.
class AnimalSoundCard extends StatelessWidget {
  const AnimalSoundCard({super.key, required this.sound, this.player});

  final AnimalSound sound;
  final SoundPlaybackController? player;

  SoundPlaybackController get _player => player ?? SoundPlayer.instance;

  Future<void> _onTap(BuildContext context) async {
    if (!sound.hasAudio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Áudio em breve — será adicionado apenas com licença adequada.',
          ),
        ),
      );
      return;
    }
    try {
      await _player.toggle(sound.assetPath!);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível tocar o som.')),
        );
      }
    }
  }

  void _showLicense(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${sound.emoji}  ${sound.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fonte: ${sound.source}'),
              const SizedBox(height: AppSpacing.sm),
              Text('Autor: ${sound.author}'),
              const SizedBox(height: AppSpacing.sm),
              Text('Licença: ${sound.license}'),
              const SizedBox(height: AppSpacing.sm),
              SelectableText(sound.licenseUrl),
              const SizedBox(height: AppSpacing.sm),
              SelectableText(sound.sourceUrl),
              if (sound.modification.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('Arquivo local: ${sound.modification}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.cardRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Tooltip(
                  message: 'Fonte e licença',
                  child: IconButton(
                    onPressed: () => _showLicense(context),
                    icon: const Icon(Icons.info_outline_rounded, size: 19),
                    color: AppColors.inkMuted,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    sound.emoji,
                    style: const TextStyle(fontSize: 54),
                  ),
                ),
              ),
              Text(sound.name, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              ValueListenableBuilder<String?>(
                valueListenable: _player.playing,
                builder: (context, playingPath, _) {
                  final isPlaying =
                      sound.hasAudio && playingPath == sound.assetPath;
                  return _PlayState(
                    hasAudio: sound.hasAudio,
                    isPlaying: isPlaying,
                    animalName: sound.name,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayState extends StatelessWidget {
  const _PlayState({
    required this.hasAudio,
    required this.isPlaying,
    required this.animalName,
  });

  final bool hasAudio;
  final bool isPlaying;
  final String animalName;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String label, Color fg, Color bg) = switch ((
      hasAudio,
      isPlaying,
    )) {
      (false, _) => (
        Icons.hourglass_empty_rounded,
        'Som em breve',
        AppColors.inkMuted,
        AppColors.pendingBg,
      ),
      (true, true) => (
        Icons.stop_rounded,
        'Parar',
        AppColors.healthyFg,
        AppColors.healthyBg,
      ),
      (true, false) => (
        Icons.play_arrow_rounded,
        'Tocar',
        AppColors.healthyFg,
        AppColors.healthyBg,
      ),
    };

    return Semantics(
      label: isPlaying
          ? 'Parar som de $animalName'
          : hasAudio
          ? 'Tocar som de $animalName'
          : 'Som de $animalName em breve',
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
