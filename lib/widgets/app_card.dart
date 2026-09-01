import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Quiet grouped surface used across Cresce. Borders are opt-in; hierarchy is
/// normally created with spacing and surface contrast rather than chrome.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.color,
    this.borderColor,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: AppRadii.cardRadius,
      side: borderColor == null
          ? BorderSide.none
          : BorderSide(color: borderColor!),
    );

    final card = Material(
      color: color ?? AppColors.surface,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        button: onTap != null,
        container: true,
        child: card,
      );
    }
    return card;
  }
}
