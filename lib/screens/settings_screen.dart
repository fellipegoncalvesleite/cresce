import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';
import '../widgets/disclaimer_note.dart';
import '../widgets/section_header.dart';
import 'legal_document_screen.dart';

/// Local settings for appearance, Home content and showcase reset.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmResetDemo(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar demonstração?'),
        content: const Text(
          'Os dados atuais do perfil serão substituídos pelos dados de exemplo '
          'da Lia. Tema e preferências da Página inicial serão preservados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirm-reset-demo-data'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppState>().resetDemoData();
    }
  }

  void _openLegal(BuildContext context, LegalDocumentType type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => LegalDocumentScreen(type: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const SectionHeader(
              title: 'Aparência',
              subtitle: 'Escolha o tema do aplicativo.',
            ),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ThemeOption(
                    label: 'Padrão do sistema',
                    icon: Icons.brightness_auto_outlined,
                    value: ThemeMode.system,
                    selected: appState.themeMode,
                    onTap: appState.setThemeMode,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _ThemeOption(
                    label: 'Claro',
                    icon: Icons.light_mode_outlined,
                    value: ThemeMode.light,
                    selected: appState.themeMode,
                    onTap: appState.setThemeMode,
                  ),
                  const Divider(height: AppSpacing.lg),
                  _ThemeOption(
                    label: 'Escuro',
                    icon: Icons.dark_mode_outlined,
                    value: ThemeMode.dark,
                    selected: appState.themeMode,
                    onTap: appState.setThemeMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(
              title: 'Página inicial',
              subtitle: 'Escolha quais resumos locais aparecem no seu dia.',
            ),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    value: appState.vaccineRemindersEnabled,
                    onChanged: appState.setVaccineRemindersEnabled,
                    title: const Text('Lembretes de vacina'),
                    subtitle: const Text('Mostra o resumo de vacinas na Home.'),
                    secondary: const Icon(Icons.vaccines_outlined),
                  ),
                  SwitchListTile(
                    value: appState.weeklyTipsEnabled,
                    onChanged: appState.setWeeklyTipsEnabled,
                    title: const Text('Dicas para esta fase'),
                    subtitle: const Text('Mostra uma dica diária na Home.'),
                    secondary: const Icon(Icons.tips_and_updates_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Demonstração'),
            AppCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                key: const Key('reset-demo-data'),
                leading: const Icon(Icons.restart_alt_outlined),
                title: const Text('Restaurar demonstração'),
                subtitle: const Text('Repõe o perfil de exemplo da Lia.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmResetDemo(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Sobre'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Versão'),
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(color: AppColors.inkMuted),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Termos de uso'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openLegal(context, LegalDocumentType.terms),
                  ),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Política de privacidade'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openLegal(context, LegalDocumentType.privacy),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const DisclaimerNote(
              text:
                  'Estas opções alteram apenas o conteúdo local da Página inicial; não agendam notificações nem enviam e-mails.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final ThemeMode value;
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return InkWell(
      onTap: () => onTap(value),
      borderRadius: BorderRadius.circular(AppRadii.field),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.inkMuted,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : AppColors.ink,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary)
            else
              Icon(Icons.circle_outlined, color: AppColors.hairline),
          ],
        ),
      ),
    );
  }
}
