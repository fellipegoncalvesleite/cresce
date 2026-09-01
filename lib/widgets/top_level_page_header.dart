import 'package:flutter/material.dart';

import '../screens/account_screen.dart';
import '../theme/app_tokens.dart';

void openAccount(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const AccountScreen()));
}

/// Shared chrome for the four top-level destinations.
class TopLevelPageHeader extends StatelessWidget {
  const TopLevelPageHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: theme.textTheme.headlineLarge),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Tooltip(
          message: 'Abrir perfil',
          child: Material(
            color: AppColors.groupedSurface,
            shape: const CircleBorder(),
            child: InkWell(
              key: const Key('top-level-profile-button'),
              customBorder: const CircleBorder(),
              onTap: () => openAccount(context),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.person_outline_rounded, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
