import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class ShapesActivityScreen extends StatefulWidget {
  const ShapesActivityScreen({super.key});

  @override
  State<ShapesActivityScreen> createState() => _ShapesActivityScreenState();
}

class _ShapesActivityScreenState extends State<ShapesActivityScreen> {
  static const _targets = ['circle', 'square', 'triangle'];
  int _targetIndex = 0;
  String? _feedback;

  String get _target => _targets[_targetIndex];

  String get _targetLabel => switch (_target) {
    'circle' => 'círculo',
    'square' => 'quadrado',
    _ => 'triângulo',
  };

  void _choose(String value) {
    setState(() {
      _feedback = value == _target ? 'Encontrou!' : 'Tente outra forma junto.';
    });
  }

  void _next() {
    setState(() {
      _targetIndex = (_targetIndex + 1) % _targets.length;
      _feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formas e cores')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Text(
                'Toque no $_targetLabel',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Nomeiem a forma juntos. Não tem pontuação nem pressa.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _ShapeChoice(
                          key: const Key('shape-circle'),
                          semanticLabel: 'Círculo',
                          onTap: () => _choose('circle'),
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        _ShapeChoice(
                          key: const Key('shape-square'),
                          semanticLabel: 'Quadrado',
                          onTap: () => _choose('square'),
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        _ShapeChoice(
                          key: const Key('shape-triangle'),
                          semanticLabel: 'Triângulo',
                          onTap: () => _choose('triangle'),
                          child: Icon(
                            Icons.change_history_rounded,
                            size: 108,
                            color: AppColors.aboveFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 84,
                child: Column(
                  children: [
                    if (_feedback != null)
                      Text(
                        _feedback!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (_feedback == 'Encontrou!') ...[
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: _next,
                        child: const Text('Outra forma'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShapeChoice extends StatelessWidget {
  const _ShapeChoice({
    super.key,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkResponse(
        onTap: onTap,
        radius: 58,
        child: SizedBox(width: 104, height: 120, child: Center(child: child)),
      ),
    );
  }
}
