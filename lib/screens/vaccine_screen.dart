import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/vaccine_schedule.dart';
import '../services/app_state.dart';
import '../services/vaccine_summary.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';
import '../widgets/disclaimer_note.dart';
import '../widgets/section_header.dart';
import '../widgets/top_level_page_header.dart';
import '../widgets/vaccination_finder_card.dart';
import '../widgets/vaccine_milestone_card.dart';

class VaccineScreen extends StatelessWidget {
  const VaccineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final summary = calculateVaccineProgressSummary(
      schedule: vaccineSchedule,
      babyAgeMonths: appState.babyAgeMonths,
      recordFor: appState.recordFor,
    );
    final nextMilestone = nextRelevantVaccineMilestone(
      schedule: vaccineSchedule,
      babyAgeMonths: appState.babyAgeMonths,
      recordFor: appState.recordFor,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              children: [
                const TopLevelPageHeader(
                  title: 'Vacinas',
                  subtitle:
                      'Calendário Nacional de Vacinação da Criança (PNI).',
                ),
                const SizedBox(height: AppSpacing.xl),
                _ProgressCard(summary: summary),
                const SizedBox(height: AppSpacing.md),
                _NextVaccineCard(
                  ageKnown: appState.babyAgeMonths != null,
                  milestone: nextMilestone,
                ),
                const SizedBox(height: AppSpacing.md),
                _BirthDateCard(appState: appState),
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeader(
                  title: 'Calendário por idade',
                  subtitle: 'Registros organizados em ordem cronológica.',
                ),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < vaccineSchedule.length; i++) ...[
                        VaccineMilestoneCard(item: vaccineSchedule[i]),
                        if (i != vaccineSchedule.length - 1)
                          Divider(
                            height: 1,
                            indent: AppSpacing.xl,
                            endIndent: AppSpacing.xl,
                            color: AppColors.hairline,
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const VaccinationFinderCard(),
                const SizedBox(height: AppSpacing.lg),
                const DisclaimerNote(
                  icon: Icons.health_and_safety_outlined,
                  text:
                      'O calendário pode variar conforme histórico vacinal, '
                      'campanhas, município, disponibilidade e orientação '
                      'profissional. Consulte a UBS ou profissional de saúde.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.summary});

  final VaccineProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final pct = summary.completion;
    if (pct == null) {
      return AppCard(
        color: AppColors.groupedSurface,
        child: const Text(
          'Adicione a data de nascimento para acompanhar o calendário por idade.',
        ),
      );
    }

    final theme = Theme.of(context);
    final percent = '${(pct * 100).round()}%';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vacinas esperadas até agora',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${summary.takenDue} de ${summary.dueTotal} registradas',
            style: theme.textTheme.titleLarge,
          ),
          if (summary.overdue > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${summary.overdue} ${summary.overdue == 1 ? "ainda não registrada" : "ainda não registradas"}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 7,
                    backgroundColor: AppColors.groupedSurface,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                percent,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextVaccineCard extends StatelessWidget {
  const _NextVaccineCard({required this.ageKnown, required this.milestone});

  final bool ageKnown;
  final VaccineNextMilestone? milestone;

  @override
  Widget build(BuildContext context) {
    if (!ageKnown) {
      return AppCard(
        color: AppColors.groupedSurface,
        child: const Text(
          'Adicione a data de nascimento para ver o que vem a seguir.',
        ),
      );
    }

    final item = milestone;
    if (item == null) {
      return AppCard(
        color: AppColors.healthyBg,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendário registrado',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppSpacing.xs),
            Text('Não há outra vacina pendente no calendário representado.'),
          ],
        ),
      );
    }

    final vaccines = item.vaccines;
    final title = item.isOverdue ? 'Atenção ao calendário' : 'Próximas';
    final primary = vaccines.length == 1
        ? '${vaccines.first.name} · ${vaccines.first.dose}'
        : '${vaccines.length} vacinas ainda não registradas aos ${item.ageLabel}';
    final secondary = 'Previstas para ${item.ageLabel}';
    final tint = item.isOverdue ? AppColors.lateBg : AppColors.groupedSurface;
    final accent = item.isOverdue ? AppColors.lateFg : AppColors.primaryDark;

    return AppCard(
      color: tint,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.72),
              borderRadius: AppRadii.fieldRadius,
            ),
            child: Icon(
              item.isOverdue
                  ? Icons.schedule_rounded
                  : Icons.event_available_outlined,
              color: accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(primary, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  secondary,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BirthDateCard extends StatelessWidget {
  const _BirthDateCard({required this.appState});

  final AppState appState;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: appState.birthDate ?? now,
      firstDate: DateTime(now.year - 6),
      lastDate: now,
      helpText: 'Data de nascimento do bebê',
    );
    if (picked != null && context.mounted) {
      appState.setBirthDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final birth = appState.birthDate;
    final months = appState.babyAgeMonths;
    final theme = Theme.of(context);
    final isDemoProfile = appState.isDemoProfile;

    return AppCard(
      key: const Key('vaccine-birth-date-card'),
      color: AppColors.groupedSurface,
      onTap: isDemoProfile ? () => openAccount(context) : () => _pick(context),
      semanticLabel: isDemoProfile
          ? 'Data de nascimento da demonstração. Vá para Conta para começar com seu bebê.'
          : 'Definir data de nascimento do bebê',
      child: Row(
        children: [
          Icon(Icons.cake_outlined, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDemoProfile
                      ? 'Perfil de demonstração'
                      : birth == null
                      ? 'Definir data de nascimento'
                      : 'Nascimento: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(birth)}',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isDemoProfile
                      ? 'Para alterar a idade, escolha “Começar com meu bebê” na Conta.'
                      : birth == null
                      ? 'Ajuda a mostrar o que está próximo ou atrasado.'
                      : '${months ?? 0} meses de vida',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted),
        ],
      ),
    );
  }
}
