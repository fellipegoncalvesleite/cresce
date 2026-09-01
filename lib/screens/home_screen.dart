import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/baby_messages.dart';
import '../data/baby_tips.dart';
import '../data/vaccine_schedule.dart';
import '../models/baby_activity.dart';
import '../models/growth.dart';
import '../models/media.dart';
import '../services/app_state.dart';
import '../services/stimulation_recommendations.dart';
import '../services/vaccine_summary.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';
import 'settings_screen.dart';

/// Daily snapshot that ties together the locally persisted Cresce systems.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.referenceDate});

  final DateTime? referenceDate;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
    final date = referenceDate ?? DateTime.now();
    final ageMonths = appState.babyAgeMonths;
    final message = messageForDay(date: date, ageMonths: ageMonths);
    final daily = recommendationsForDay(date: date, ageMonths: ageMonths);
    final tip = appState.weeklyTipsEnabled
        ? tipForDay(date: date, ageMonths: ageMonths)
        : null;
    final vaccineMilestone = appState.vaccineRemindersEnabled
        ? nextRelevantVaccineMilestone(
            schedule: vaccineSchedule,
            babyAgeMonths: ageMonths,
            recordFor: appState.recordFor,
          )
        : null;
    final latestGrowth = appState.latestGrowthRecord;
    final growthStatus = appState.growthStatus;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cresce'),
        actions: [
          IconButton(
            onPressed: () => appState.toggleTheme(theme.brightness),
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: isDark ? 'Tema claro' : 'Tema escuro',
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            _IdentityCard(
              babyName: appState.babyName,
              ageMonths: ageMonths,
              isDemoProfile: appState.isDemoProfile,
              message: message.text,
              growthStatus: growthStatus,
            ),
            if (ageMonths == null) ...[
              const SizedBox(height: AppSpacing.md),
              _SnapshotCard(
                key: const Key('home-birth-cta'),
                icon: Icons.cake_outlined,
                title: 'Personalize o dia',
                headline:
                    'Adicione a data de nascimento para personalizar as sugestões.',
                semanticLabel: 'Adicionar data de nascimento no perfil',
                onTap: () => appState.selectTab(4),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            _GrowthSnapshot(
              record: latestGrowth,
              status: growthStatus,
              onTap: () => appState.selectTab(1),
            ),
            if (appState.vaccineRemindersEnabled) ...[
              const SizedBox(height: AppSpacing.md),
              _VaccineSnapshot(
                ageKnown: ageMonths != null,
                milestone: vaccineMilestone,
                onTap: () => appState.selectTab(2),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _SnapshotCard(
              key: const Key('home-activity-card'),
              icon: Icons.toys_outlined,
              title: 'Hoje',
              headline: daily.activity.title,
              detail:
                  '${daily.activity.durationMinutes} min · ${_categoryLabel(daily.activity.category)}',
              semanticLabel: 'Atividade de hoje: ${daily.activity.title}',
              onTap: () => appState.selectTab(3),
            ),
            if (tip != null) ...[
              const SizedBox(height: AppSpacing.md),
              _SnapshotCard(
                icon: Icons.tips_and_updates_outlined,
                title: 'Dica para esta fase',
                headline: tip.text,
                detail: tip.category,
                semanticLabel: 'Dica para esta fase: ${tip.text}',
              ),
            ],
            if (daily.story != null || daily.song != null) ...[
              const SizedBox(height: AppSpacing.md),
              _CalmSnapshot(
                story: daily.story,
                song: daily.song,
                onTap: () => appState.selectTab(3),
              ),
            ],
            if (appState.parent1Name.isEmpty &&
                appState.parent2Name.isEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _SnapshotCard(
                key: const Key('home-caregiver-cta'),
                icon: Icons.people_outline,
                title: 'Responsáveis',
                headline: 'Adicione quem cuida do bebê no perfil.',
                semanticLabel: 'Adicionar responsáveis no perfil',
                onTap: () => appState.selectTab(4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.babyName,
    required this.ageMonths,
    required this.isDemoProfile,
    required this.message,
    required this.growthStatus,
  });

  final String babyName;
  final int? ageMonths;
  final bool isDemoProfile;
  final String message;
  final GrowthStatus? growthStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final identity = ageMonths == null
        ? babyName
        : '$babyName · $ageMonths meses';

    return AppCard(
      semanticLabel: isDemoProfile
          ? '$identity. Perfil de demonstração. $message'
          : '$identity. $message',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: growthStatus == null
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.healthyBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.child_care_outlined,
                      color: AppColors.healthyFg,
                      size: 30,
                    ),
                  )
                : Image.asset(
                    growthStatus!.illustrationAsset,
                    semanticLabel: growthStatus!.illustrationSemanticLabel,
                    fit: BoxFit.contain,
                  ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        identity,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (isDemoProfile) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadii.chip),
                          border: Border.all(color: AppColors.hairline),
                        ),
                        child: Text(
                          'Demonstração',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.inkMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthSnapshot extends StatelessWidget {
  const _GrowthSnapshot({
    required this.record,
    required this.status,
    required this.onTap,
  });

  final GrowthRecord? record;
  final GrowthStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final measurement = record?.measurement;
    if (measurement == null || status == null) {
      return _SnapshotCard(
        key: const Key('home-growth-card'),
        icon: Icons.monitor_weight_outlined,
        title: 'Crescimento',
        headline: 'Registre peso e tamanho para acompanhar o histórico.',
        semanticLabel: 'Crescimento sem medidas. Registrar primeira medida',
        onTap: onTap,
      );
    }

    return _SnapshotCard(
      key: const Key('home-growth-card'),
      icon: status!.icon,
      title: 'Crescimento',
      headline:
          '${_formatNumber(measurement.weightKg, forceDecimal: true)} kg · ${_formatNumber(measurement.lengthCm)} cm',
      detail: status!.label,
      semanticLabel:
          'Crescimento: ${_formatNumber(measurement.weightKg, forceDecimal: true)} quilos, ${_formatNumber(measurement.lengthCm)} centímetros. ${status!.label}',
      onTap: onTap,
    );
  }
}

class _VaccineSnapshot extends StatelessWidget {
  const _VaccineSnapshot({
    required this.ageKnown,
    required this.milestone,
    required this.onTap,
  });

  final bool ageKnown;
  final VaccineNextMilestone? milestone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String headline;
    if (!ageKnown) {
      headline = 'Adicione a data de nascimento para acompanhar o calendário.';
    } else if (milestone == null) {
      headline = 'Calendário representado em dia.';
    } else if (milestone!.isOverdue) {
      final count = milestone!.vaccines.length;
      headline =
          '$count ${count == 1 ? 'registro pendente' : 'registros pendentes'} · ${milestone!.ageLabel}';
    } else if (milestone!.vaccines.length == 1) {
      headline = '${milestone!.vaccines.first.name} · ${milestone!.ageLabel}';
    } else {
      headline =
          '${milestone!.vaccines.length} registros previstos · ${milestone!.ageLabel}';
    }

    return _SnapshotCard(
      key: const Key('home-vaccine-card'),
      icon: Icons.vaccines_outlined,
      title: milestone?.isOverdue == true ? 'Vacinas' : 'Próximas',
      headline: headline,
      semanticLabel: 'Vacinas: $headline',
      onTap: onTap,
    );
  }
}

class _CalmSnapshot extends StatelessWidget {
  const _CalmSnapshot({
    required this.story,
    required this.song,
    required this.onTap,
  });

  final Story? story;
  final Song? song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedStory = story;
    final headline = selectedStory?.title ?? song!.title;
    final detail = selectedStory != null
        ? '${selectedStory.readingMinutes} min de leitura'
        : '${song!.moment.label} · ${song!.suggestion}';

    return _SnapshotCard(
      key: const Key('home-calm-card'),
      icon: selectedStory != null
          ? Icons.auto_stories_outlined
          : Icons.music_note_outlined,
      title: 'Para acalmar',
      headline: headline,
      detail: detail,
      semanticLabel: 'Para acalmar: $headline',
      onTap: onTap,
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({
    super.key,
    required this.icon,
    required this.title,
    required this.headline,
    required this.semanticLabel,
    this.detail,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String headline;
  final String? detail;
  final String semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      semanticLabel: semanticLabel,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadii.field),
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  headline,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (detail != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    detail!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right, color: AppColors.inkMuted),
          ],
        ],
      ),
    );
  }
}

String _formatNumber(double value, {bool forceDecimal = false}) {
  if (!forceDecimal && value % 1 == 0) return value.toStringAsFixed(0);
  final digits = forceDecimal ? 1 : (value % 1 == 0 ? 0 : 1);
  return value.toStringAsFixed(digits).replaceAll('.', ',');
}

String _categoryLabel(BabyActivityCategory category) => switch (category) {
  BabyActivityCategory.movement => 'movimento',
  BabyActivityCategory.language => 'linguagem',
  BabyActivityCategory.sensory => 'sensorial',
  BabyActivityCategory.social => 'conexão',
  BabyActivityCategory.calm => 'calma',
  BabyActivityCategory.play => 'brincadeira',
};
