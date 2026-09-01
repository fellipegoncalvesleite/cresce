import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

enum LegalDocumentType { terms, privacy }

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.type});

  final LegalDocumentType type;

  @override
  Widget build(BuildContext context) {
    final isTerms = type == LegalDocumentType.terms;
    final sections = isTerms ? _termsSections : _privacySections;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTerms ? 'Termos de uso' : 'Política de privacidade'),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              children: [
                for (var i = 0; i < sections.length; i++) ...[
                  Semantics(
                    key: Key('legal-section-heading-$i'),
                    header: true,
                    child: Text(
                      sections[i].title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    sections[i].body,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.55),
                  ),
                  if (i != sections.length - 1)
                    const SizedBox(height: AppSpacing.xxl),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalSection {
  const _LegalSection(this.title, this.body);

  final String title;
  final String body;
}

const _termsSections = <_LegalSection>[
  _LegalSection(
    'Finalidade',
    'Cresce é um aplicativo informativo e de demonstração. Ele não substitui diagnóstico, tratamento, consulta médica ou avaliação individual de um profissional de saúde.',
  ),
  _LegalSection(
    'Crescimento e vacinas',
    'Informações sobre crescimento e vacinação são orientativas. Quando relevante, confirme dados, condutas e calendário com profissionais de saúde e fontes oficiais.',
  ),
  _LegalSection(
    'Atividades com crianças',
    'As atividades propostas devem ser adequadas à criança, feitas com supervisão de um responsável e interrompidas se houver desconforto, cansaço ou risco.',
  ),
  _LegalSection(
    'Serviços externos',
    'Buscas e conteúdos abertos em serviços externos seguem os termos e políticas desses próprios provedores. Cresce não controla o conteúdo ou a disponibilidade desses serviços.',
  ),
];

const _privacySections = <_LegalSection>[
  _LegalSection(
    'Armazenamento local',
    'Dados de bebê, perfil, crescimento, vacinas e preferências são armazenados localmente neste aparelho. O login de demonstração não usa servidor de autenticação.',
  ),
  _LegalSection(
    'Localização',
    'Cresce não solicita sua localização GPS para procurar vacinação. A busca é encaminhada ao Google Maps ou ao Google Search, que aplicam suas próprias políticas.',
  ),
  _LegalSection(
    'Serviços externos',
    'Google Maps, Google Search, YouTube e Spotify são serviços externos abertos por encaminhamento. Eles não são controlados pelo Cresce e podem tratar dados conforme suas próprias políticas.',
  ),
  _LegalSection(
    'Sons incluídos',
    'Os sons distribuídos dentro do aplicativo têm suas fontes, autores, licenças e atribuições documentados no arquivo de licenças de assets do projeto.',
  ),
];
