import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_tokens.dart';
import '../widgets/app_card.dart';
import '../widgets/disclaimer_note.dart';
import '../widgets/section_header.dart';
import 'settings_screen.dart';

/// Local family/profile hub. Cresce does not provide network authentication.
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final TextEditingController _name;
  late final TextEditingController _parent1;
  late final TextEditingController _parent2;
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _profileSignature;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _name = TextEditingController();
    _parent1 = TextEditingController();
    _parent2 = TextEditingController();
    _syncControllers(state, force: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncControllers(context.watch<AppState>());
  }

  @override
  void dispose() {
    _name.dispose();
    _parent1.dispose();
    _parent2.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _syncControllers(AppState state, {bool force = false}) {
    final signature = [
      state.babyName,
      state.parent1Name,
      state.parent2Name,
      state.isDemoProfile,
    ].join('|');
    if (!force && signature == _profileSignature) return;
    _profileSignature = signature;
    _name.text = state.babyName == 'bebê' ? '' : state.babyName;
    _parent1.text = state.parent1Name;
    _parent2.text = state.parent2Name;
  }

  Future<void> _saveProfile() async {
    final state = context.read<AppState>();
    if (state.isDemoProfile) return;
    FocusScope.of(context).unfocus();
    await state.updateBabyName(_name.text);
    await state.setParents(parent1: _parent1.text, parent2: _parent2.text);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil atualizado.')));
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um e-mail válido.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    await context.read<AppState>().login(email);
    _password.clear();
  }

  Future<void> _startPersonalProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Começar com meu bebê?'),
        content: const Text(
          'Os dados de exemplo da Lia, incluindo medidas e vacinas, serão '
          'removidos. As preferências do aplicativo serão preservadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirm-start-personal-profile'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Começar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AppState>().startPersonalProfile();
  }

  Future<void> _pickBirthDate(AppState state) async {
    if (state.isDemoProfile) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.birthDate ?? now,
      firstDate: DateTime(now.year - 6),
      lastDate: now,
      helpText: 'Data de nascimento do bebê',
      cancelText: 'Cancelar',
      confirmText: 'Salvar',
    );
    if (picked != null && mounted) {
      await state.setBirthDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: [
                _ProfileHeader(appState: appState),
                const SizedBox(height: AppSpacing.md),
                _BabySummaryCard(appState: appState),
                if (appState.isDemoProfile) ...[
                  const SizedBox(height: AppSpacing.md),
                  _DemoTransitionCard(onStart: _startPersonalProfile),
                ],
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeader(
                  title: 'Perfil da família',
                  subtitle: 'Informações locais do bebê e de quem cuida.',
                ),
                _BirthDateCard(
                  appState: appState,
                  onTap: appState.isDemoProfile
                      ? null
                      : () => _pickBirthDate(appState),
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  color: AppColors.groupedSurface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Field(
                        fieldKey: const Key('account-baby-name-field'),
                        controller: _name,
                        enabled: !appState.isDemoProfile,
                        label: 'Nome do bebê',
                        hint: 'ex.: Manuela',
                        icon: Icons.child_care_outlined,
                        capitalize: true,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _Field(
                        fieldKey: const Key('account-parent1-field'),
                        controller: _parent1,
                        enabled: !appState.isDemoProfile,
                        label: 'Responsável 1',
                        hint: 'ex.: mãe, pai…',
                        icon: Icons.person_outline,
                        capitalize: true,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _Field(
                        fieldKey: const Key('account-parent2-field'),
                        controller: _parent2,
                        enabled: !appState.isDemoProfile,
                        label: 'Responsável 2 (opcional)',
                        hint: 'ex.: mãe, pai…',
                        icon: Icons.person_outline,
                        capitalize: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton.icon(
                        onPressed: appState.isDemoProfile ? null : _saveProfile,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Salvar perfil'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const SectionHeader(
                  title: 'Conta local',
                  subtitle: 'Dados guardados apenas neste aparelho.',
                ),
                if (appState.isLoggedIn)
                  _SignedInCard(
                    email: appState.userEmail!,
                    isDemoProfile: appState.isDemoProfile,
                    onLogout: appState.logout,
                  )
                else
                  _LoginCard(
                    emailController: _email,
                    passwordController: _password,
                    onLogin: _login,
                  ),
                const SizedBox(height: AppSpacing.xxl),
                AppCard(
                  padding: EdgeInsets.zero,
                  color: AppColors.groupedSurface,
                  child: ListTile(
                    minTileHeight: 56,
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Configurações'),
                    subtitle: const Text('Aparência, Página inicial e Sobre'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final age = appState.babyAgeMonths;
    final identity = age == null
        ? appState.babyName
        : '${appState.babyName} · $age meses';
    final profileLabel = appState.isDemoProfile
        ? 'Perfil de demonstração'
        : 'Perfil pessoal';

    return AppCard(
      color: AppColors.groupedSurface,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.healthyBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.child_care_outlined,
              color: AppColors.healthyFg,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(identity, style: theme.textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  profileLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w500,
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

class _BabySummaryCard extends StatelessWidget {
  const _BabySummaryCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final birthDate = appState.birthDate;
    final measurement = appState.latestGrowthRecord?.measurement;
    final birthText = birthDate == null
        ? 'Nascimento não informado'
        : 'Nascimento: ${DateFormat('dd/MM/yyyy', 'pt_BR').format(birthDate)}';
    final measurementText = measurement == null
        ? 'Sem medidas registradas'
        : '${_decimal(measurement.weightKg)} kg · ${_length(measurement.lengthCm)} cm';

    return AppCard(
      color: AppColors.groupedSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(icon: Icons.cake_outlined, text: birthText),
          const SizedBox(height: AppSpacing.sm),
          _InfoLine(icon: Icons.straighten_outlined, text: measurementText),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: AppColors.primaryDark),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(text)),
    ],
  );
}

class _DemoTransitionCard extends StatelessWidget {
  const _DemoTransitionCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => AppCard(
    color: AppColors.accentSoft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A Lia é um perfil de demonstração com dados de exemplo.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          key: const Key('start-personal-profile'),
          onPressed: onStart,
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: const Text('Começar com meu bebê'),
        ),
      ],
    ),
  );
}

class _BirthDateCard extends StatelessWidget {
  const _BirthDateCard({required this.appState, this.onTap});

  final AppState appState;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final birthDate = appState.birthDate;
    final title = birthDate == null
        ? 'Adicionar data de nascimento'
        : 'Data de nascimento';
    final detail = birthDate == null
        ? 'Personaliza a idade, vacinas e sugestões.'
        : DateFormat('dd/MM/yyyy', 'pt_BR').format(birthDate);

    return AppCard(
      key: const Key('account-birth-date-card'),
      color: AppColors.groupedSurface,
      onTap: onTap,
      semanticLabel: appState.isDemoProfile
          ? 'Data de nascimento da demonstração. Para alterar, comece um perfil pessoal.'
          : '$title. $detail',
      child: Row(
        children: [
          Icon(Icons.cake_outlined, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  appState.isDemoProfile
                      ? '$detail · use “Começar com meu bebê” para editar'
                      : detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right, color: AppColors.inkMuted),
        ],
      ),
    );
  }
}

class _SignedInCard extends StatelessWidget {
  const _SignedInCard({
    required this.email,
    required this.isDemoProfile,
    required this.onLogout,
  });

  final String email;
  final bool isDemoProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: AppColors.groupedSurface,
      child: Row(
        children: [
          Icon(Icons.person_outline, color: AppColors.healthyFg),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDemoProfile ? 'Conta local de demonstração' : 'Conta local',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!isDemoProfile)
            OutlinedButton(onPressed: onLogout, child: const Text('Sair')),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      color: AppColors.groupedSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Conta local neste aparelho',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              hintText: 'voce@exemplo.com',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Senha de demonstração',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onLogin,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar conta local'),
          ),
          const SizedBox(height: AppSpacing.sm),
          const DisclaimerNote(
            text:
                'Não há servidor de autenticação. Estes dados ficam salvos somente neste aparelho.',
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.fieldKey,
    required this.controller,
    required this.enabled,
    required this.label,
    required this.hint,
    required this.icon,
    this.capitalize = false,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String hint;
  final IconData icon;
  final bool capitalize;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      enabled: enabled,
      textCapitalization: capitalize
          ? TextCapitalization.words
          : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

String _decimal(double value) => value.toStringAsFixed(1).replaceAll('.', ',');

String _length(double value) =>
    (value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1))
        .replaceAll('.', ',');
