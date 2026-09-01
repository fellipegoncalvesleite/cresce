import 'package:flutter/material.dart';

import '../services/external_search.dart';
import '../theme/app_tokens.dart';
import 'app_card.dart';
import 'section_header.dart';

class VaccinationFinderCard extends StatefulWidget {
  const VaccinationFinderCard({super.key});

  @override
  State<VaccinationFinderCard> createState() => _VaccinationFinderCardState();
}

class _VaccinationFinderCardState extends State<VaccinationFinderCard> {
  static const _search = ExternalSearch();
  final _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _manualController.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    _manualController
      ..removeListener(_onLocationChanged)
      ..dispose();
    super.dispose();
  }

  void _onLocationChanged() => setState(() {});

  Future<void> _open(Uri uri, String failureMessage) async {
    final ok = await _search.open(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  }

  Future<void> _openNearbyLocations() => _open(
    _search.nearbyVaccinationSearch(),
    'Não foi possível abrir o mapa neste dispositivo.',
  );

  Future<void> _openManualLocations() async {
    final place = _manualController.text.trim();
    if (place.isEmpty) return;
    await _open(
      _search.vaccinationLocationsSearch(place),
      'Não foi possível abrir o mapa neste dispositivo.',
    );
  }

  Future<void> _openCampaigns() {
    final place = _manualController.text.trim();
    return _open(
      _search.vaccinationCampaignSearch(place),
      'Não foi possível abrir a busca neste dispositivo.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasManualLocation = _manualController.text.trim().isNotEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Vacinação perto de você',
            subtitle:
                'Encontre locais de vacinação ou consulte campanhas na sua região.',
          ),
          Text(
            'Postos e UBS próximas',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Abra o mapa para procurar locais de vacinação perto de você.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: _openNearbyLocations,
            icon: const Icon(Icons.map_outlined),
            label: const Text('Ver no mapa'),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Cidade ou bairro',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _manualController,
            textInputAction: TextInputAction.search,
            onSubmitted: hasManualLocation
                ? (_) => _openManualLocations()
                : null,
            decoration: const InputDecoration(
              hintText: 'ex.: Centro, Belo Horizonte',
              prefixIcon: Icon(Icons.place_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: hasManualLocation ? _openManualLocations : null,
            icon: const Icon(Icons.search),
            label: const Text('Buscar locais'),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Campanhas e mutirões',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Consulte campanhas, mutirões e ações divulgadas pela prefeitura ou rede de saúde.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: _openCampaigns,
            icon: const Icon(Icons.travel_explore_outlined),
            label: const Text('Buscar campanhas'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'A busca abre informações externas atuais. O Cresce não mantém uma lista ao vivo de campanhas.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.inkMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
