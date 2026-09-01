import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class PeekabooActivityScreen extends StatefulWidget {
  const PeekabooActivityScreen({super.key});

  @override
  State<PeekabooActivityScreen> createState() => _PeekabooActivityScreenState();
}

class _PeekabooActivityScreenState extends State<PeekabooActivityScreen> {
  bool _revealed = false;

  void _toggle() => setState(() => _revealed = !_revealed);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 280);

    return Scaffold(
      appBar: AppBar(title: const Text('Cadê? Achou!')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Text(
                'Façam poucas repetições e conversem sobre o que aparece.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.inkMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: Center(
                  child: Semantics(
                    button: true,
                    label: _revealed
                        ? 'Esconder a forma novamente'
                        : 'Revelar a forma escondida',
                    child: InkWell(
                      key: const Key('peekaboo-toggle'),
                      borderRadius: BorderRadius.circular(40),
                      onTap: _toggle,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 220,
                          minHeight: 220,
                        ),
                        child: AnimatedSwitcher(
                          duration: duration,
                          child: _revealed
                              ? Column(
                                  key: const Key('peekaboo-revealed'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: AppColors.accentSoft,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.accent,
                                          width: 3,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.wb_sunny_outlined,
                                        size: 72,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    const Text(
                                      'Achou!',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  key: const Key('peekaboo-hidden'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.hairline,
                                          width: 3,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.help_outline_rounded,
                                        size: 72,
                                        color: AppColors.inkMuted,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    const Text(
                                      'Cadê?',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                _revealed
                    ? 'Toque para esconder e brincar de novo.'
                    : 'Toque junto para revelar.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
