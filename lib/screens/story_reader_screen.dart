import 'package:flutter/material.dart';

import '../models/media.dart';
import '../theme/app_tokens.dart';

/// A calm, generously spaced reader for a single short story.
class StoryReaderScreen extends StatelessWidget {
  const StoryReaderScreen({super.key, required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(story.title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 16,
                      color: AppColors.inkMuted,
                    ),
                    Text(
                      '${story.origin} · ${story.ageLabel} · ${story.readingMinutes} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                for (final paragraph in story.paragraphs) ...[
                  Text(
                    paragraph,
                    style: theme.textTheme.titleMedium?.copyWith(
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: Text(
                    '✿ Fim ✿',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
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
