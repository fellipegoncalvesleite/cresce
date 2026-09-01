import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/vaccine.dart';
import '../services/app_state.dart';
import '../services/external_search.dart';
import '../theme/app_tokens.dart';
import 'status_pill.dart';

/// One chronological vaccine milestone inside the grouped calendar surface.
class VaccineMilestoneCard extends StatelessWidget {
  const VaccineMilestoneCard({super.key, required this.item});

  final VaccineScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.ageLabel, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${item.vaccines.length} '
                  '${item.vaccines.length == 1 ? "vacina" : "vacinas"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < item.vaccines.length; i++) ...[
                  if (i > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    Divider(height: 1, color: AppColors.hairline),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _VaccineTile(
                    vaccine: item.vaccines[i],
                    milestoneMonths: item.ageInMonths,
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

class _VaccineTile extends StatelessWidget {
  const _VaccineTile({required this.vaccine, required this.milestoneMonths});

  final VaccineInfo vaccine;
  final int? milestoneMonths;

  static const _search = ExternalSearch();

  Future<void> _markTaken(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 6),
      lastDate: now,
      helpText: 'Quando foi tomada?',
    );
    if (picked != null && context.mounted) {
      context.read<AppState>().setVaccineTaken(
        vaccine.id,
        taken: true,
        date: picked,
      );
    }
  }

  Future<void> _findLocations(BuildContext context) async {
    final uri = _search.mapsSearch(
      'vacina ${vaccine.name} posto de vacinação perto de mim',
    );
    final ok = await _search.open(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final record = appState.recordFor(vaccine.id);
    final status = deriveVaccineStatus(
      milestoneMonths: milestoneMonths,
      babyAgeMonths: appState.babyAgeMonths,
      record: record,
    );
    final scale = MediaQuery.textScalerOf(context).scale(1);

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(vaccine.name, style: theme.textTheme.titleSmall),
        const SizedBox(height: 2),
        Text(
          vaccine.dose,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
        ),
      ],
    );
    final statusPill = StatusPill(
      label: status.label,
      icon: status.icon,
      foreground: status.foreground,
      background: status.background,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (scale > 1.35) ...[
          title,
          const SizedBox(height: AppSpacing.sm),
          statusPill,
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: title),
              const SizedBox(width: AppSpacing.sm),
              statusPill,
            ],
          ),
        const SizedBox(height: AppSpacing.sm),
        _Detail(label: 'Protege contra', value: vaccine.protectsAgainst),
        const SizedBox(height: AppSpacing.xs),
        _Detail(label: 'Observação', value: vaccine.notes),
        if (vaccine.requiresProfessionalConfirmation) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.flag_outlined, size: 16, color: AppColors.lateFg),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Confirme detalhes (produto/esquema) na UBS.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.lateFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        if (record?.taken ?? false)
          _TakenRow(record: record!, vaccineId: vaccine.id)
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              OutlinedButton.icon(
                onPressed: () => _markTaken(context),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Marcar como tomada'),
              ),
              TextButton.icon(
                onPressed: () => _findLocations(context),
                icon: const Icon(Icons.travel_explore_outlined, size: 18),
                label: const Text('Procurar locais'),
              ),
            ],
          ),
      ],
    );
  }
}

class _TakenRow extends StatelessWidget {
  const _TakenRow({required this.record, required this.vaccineId});

  final VaccineRecord record;
  final String vaccineId;

  @override
  Widget build(BuildContext context) {
    final date = record.takenDate;
    final label = date != null
        ? 'Tomada em ${DateFormat('dd/MM/yyyy', 'pt_BR').format(date)}'
        : 'Tomada';
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        Icon(Icons.check_circle, size: 18, color: AppColors.takenFg),
        Text(
          label,
          style: TextStyle(
            color: AppColors.takenFg,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () =>
              context.read<AppState>().setVaccineTaken(vaccineId, taken: false),
          child: const Text('Desfazer'),
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppColors.ink),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.inkMuted,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
