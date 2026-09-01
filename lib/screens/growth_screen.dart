import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/growth.dart';
import '../services/app_state.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';
import '../widgets/disclaimer_note.dart';
import '../widgets/empty_state.dart';
import '../widgets/growth_status_card.dart';
import '../widgets/section_header.dart';
import '../widgets/top_level_page_header.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weight;
  late final TextEditingController _length;
  late final TextEditingController _age;
  String? _measurementSignature;

  @override
  void initState() {
    super.initState();
    final m = context.read<AppState>().measurement;
    _weight = TextEditingController(text: m != null ? _fmt(m.weightKg) : '');
    _length = TextEditingController(text: m != null ? _fmt(m.lengthCm) : '');
    _age = TextEditingController(text: m?.ageMonths?.toString() ?? '');
    _measurementSignature = _signature(m);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMeasurementControllers(context.watch<AppState>().measurement);
  }

  String _fmt(double v) =>
      (v % 1 == 0 ? v.toStringAsFixed(0) : v.toString()).replaceAll('.', ',');

  String _fmtWeight(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

  String _fmtLength(double v) =>
      (v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1)).replaceAll(
        '.',
        ',',
      );

  String _signature(GrowthMeasurement? measurement) => measurement == null
      ? 'none'
      : '${measurement.weightKg}|${measurement.lengthCm}|${measurement.ageMonths}';

  void _syncMeasurementControllers(GrowthMeasurement? measurement) {
    final signature = _signature(measurement);
    if (_measurementSignature == signature) return;
    _measurementSignature = signature;
    _weight.text = measurement == null ? '' : _fmt(measurement.weightKg);
    _length.text = measurement == null ? '' : _fmt(measurement.lengthCm);
    _age.text = measurement?.ageMonths?.toString() ?? '';
  }

  double? _parse(String raw) =>
      double.tryParse(raw.trim().replaceAll(',', '.'));

  @override
  void dispose() {
    _weight.dispose();
    _length.dispose();
    _age.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final measurement = GrowthMeasurement(
      weightKg: _parse(_weight.text)!,
      lengthCm: _parse(_length.text)!,
      ageMonths: int.tryParse(_age.text.trim()),
    );
    context.read<AppState>().setMeasurement(measurement);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Orientação atualizada.')));
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final status = appState.growthStatus;
    final measurement = appState.measurement;
    final recentHistory = appState.growthHistory.reversed.take(4).toList();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              children: [
                const TopLevelPageHeader(
                  title: 'Crescimento',
                  subtitle: 'Peso e tamanho em uma leitura simples.',
                ),
                const SizedBox(height: AppSpacing.xl),
                if (status != null && measurement != null) ...[
                  GrowthStatusCard(status: status),
                  const SizedBox(height: AppSpacing.md),
                  _MeasurementSummary(
                    measurement: measurement,
                    weight: _fmtWeight(measurement.weightKg),
                    length: _fmtLength(measurement.lengthCm),
                  ),
                ] else
                  AppCard(
                    color: AppColors.groupedSurface,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                      horizontal: AppSpacing.lg,
                    ),
                    child: const EmptyState(
                      icon: Icons.straighten_rounded,
                      title: 'Sem medidas ainda',
                      message:
                          'Informe o peso e o comprimento atuais para ver a orientação.',
                    ),
                  ),
                const SizedBox(height: AppSpacing.xxl),
                Semantics(
                  key: const Key('growth-history-heading'),
                  header: true,
                  child: Text(
                    'Histórico recente',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (recentHistory.isEmpty)
                  AppCard(
                    color: AppColors.groupedSurface,
                    child: const Text(
                      'As medidas registradas vão aparecer aqui.',
                    ),
                  )
                else
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xs,
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < recentHistory.length; i++) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: _HistoryRow(
                              key: Key('growth-history-$i'),
                              record: recentHistory[i],
                              weight: _fmtWeight(
                                recentHistory[i].measurement.weightKg,
                              ),
                              length: _fmtLength(
                                recentHistory[i].measurement.lengthCm,
                              ),
                            ),
                          ),
                          if (i != recentHistory.length - 1)
                            Divider(height: 1, color: AppColors.hairline),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeader(
                  title: 'Adicionar medida',
                  subtitle: 'O formulário fica separado da orientação atual.',
                ),
                AppCard(
                  color: AppColors.groupedSurface,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medidas atuais',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final scale = MediaQuery.textScalerOf(
                              context,
                            ).scale(1);
                            final stackFields =
                                constraints.maxWidth < 400 || scale > 1.3;
                            final weight = _NumberField(
                              fieldKey: const Key('growth-weight-field'),
                              controller: _weight,
                              label: 'Peso (kg)',
                              hint: 'ex.: 5,8',
                              validator: (v) => _parse(v ?? '') == null
                                  ? 'Informe o peso'
                                  : null,
                            );
                            final length = _NumberField(
                              fieldKey: const Key('growth-length-field'),
                              controller: _length,
                              label: 'Comprimento (cm)',
                              hint: 'ex.: 60',
                              validator: (v) => _parse(v ?? '') == null
                                  ? 'Informe o tamanho'
                                  : null,
                            );
                            if (stackFields) {
                              return Column(
                                children: [
                                  weight,
                                  const SizedBox(height: AppSpacing.md),
                                  length,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: weight),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(child: length),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _NumberField(
                          fieldKey: const Key('growth-age-field'),
                          controller: _age,
                          label: 'Idade em meses (opcional)',
                          hint: 'ex.: 4',
                          validator: (_) => null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Registrar medida'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const DisclaimerNote(
                  text:
                      'Essa informação é apenas uma orientação e não '
                      'substitui avaliação médica.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MeasurementSummary extends StatelessWidget {
  const _MeasurementSummary({
    required this.measurement,
    required this.weight,
    required this.length,
  });

  final GrowthMeasurement measurement;
  final String weight;
  final String length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: AppColors.groupedSurface,
      child: Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.md,
        children: [
          _Metric(label: 'Peso', value: '$weight kg'),
          _Metric(label: 'Comprimento', value: '$length cm'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Estimativa simples',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'IMC ~${measurement.bmi.toStringAsFixed(1).replaceAll('.', ',')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.inkMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    super.key,
    required this.record,
    required this.weight,
    required this.length,
  });

  final GrowthRecord record;
  final String weight;
  final String length;

  @override
  Widget build(BuildContext context) {
    final ageMonths = record.measurement.ageMonths;
    final details = <String>[
      DateFormat('dd/MM/yyyy', 'pt_BR').format(record.recordedAt),
      if (ageMonths != null) '$ageMonths meses',
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Container(
            width: 9,
            height: 9,
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
              Text(
                '$weight kg · $length cm',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                details,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    this.fieldKey,
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
