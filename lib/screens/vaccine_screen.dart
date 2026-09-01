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
      appBar: AppBar(title: const Text('Vacinas')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const SectionHeader(
              title: 'Vacinas',
              subtitle: 'Calendário Nacional de Vacinação da Criança (PNI).',
            ),
            _ProgressCard(summary: summary),
            const SizedBox(height: AppSpacing.lg),
            _NextVaccineCard(
              ageKnown: appState.babyAgeMonths != null,
              milestone: nextMilestone,
            ),
            const SizedBox(height: AppSpacing.lg),
            _BirthDateCard(appState: appState),
            const SizedBox(height: AppSpacing.lg),
            const VaccinationFinderCard(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Calendário por idade',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final item in vaccineSchedule) ...[
              VaccineMilestoneCard(item: item),
              const SizedBox(height: AppSpacing.md),
            ],
            const SizedBox(height: AppSpacing.sm),
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
      return const AppCard(
        child: Text(
          'Adicione a data de nascimento para acompanhar o calendário por idade.',
        ),
      );
    }

    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 5,
                  backgroundColor: AppColors.hairline,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                Text(
                  '${(pct * 100).round()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vacinas esperadas até agora',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '${summary.takenDue} de ${summary.dueTotal} registradas',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                ),
                if (summary.overdue > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${summary.overdue} ${summary.overdue == 1 ? "ainda não registrada" : "ainda não registradas"}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                  ),
                ],
              ],
            ),
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
      return const AppCard(
        child: Text(
          'Adicione a data de nascimento para ver o que vem a seguir.',
        ),
      );
    }

    final item = milestone;
    if (item == null) {
      return const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendário registrado',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
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
    final secondary = item.isOverdue
        ? 'Previstas para ${item.ageLabel}'
        : 'Previstas para ${item.ageLabel}';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(primary),
          const SizedBox(height: 2),
          Text(
            secondary,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
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
      onTap: isDemoProfile ? () => appState.selectTab(4) : () => _pick(context),
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
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
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
          Icon(Icons.chevron_right, color: AppColors.inkMuted),
        ],
      ),
    );
  }
}
