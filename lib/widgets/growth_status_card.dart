import 'package:flutter/material.dart';

import '../models/growth.dart';
import '../theme/app_tokens.dart';

/// Visual anchor for the current CP1 growth band. The illustration supports the
/// result; text and icon remain the authoritative status signals.
class GrowthStatusCard extends StatefulWidget {
  const GrowthStatusCard({super.key, required this.status, this.caption});

  final GrowthStatus status;

  /// Optional quiet metadata retained for compatibility with existing callers.
  final String? caption;

  @override
  State<GrowthStatusCard> createState() => _GrowthStatusCardState();
}

class _GrowthStatusCardState extends State<GrowthStatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  @override
  void initState() {
    super.initState();
    _entry.forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final theme = Theme.of(context);

    final baby = SizedBox(
      width: 140,
      height: 140,
      child: Image.asset(
        status.illustrationAsset,
        fit: BoxFit.contain,
        semanticLabel: status.illustrationSemanticLabel,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: AppRadii.cardRadius,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          if (reduceMotion)
            baby
          else
            FadeTransition(
              opacity: _entry,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(
                  CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic),
                ),
                child: baby,
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            header: true,
            label: 'Situação: ${status.label}',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(status.icon, size: 24, color: status.foreground),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    status.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: status.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            status.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.lg),
          _NextStep(text: status.nextStep, accent: status.foreground),
          if (widget.caption != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.caption!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({required this.text, required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.78),
        borderRadius: AppRadii.fieldRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 18, color: accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
