import 'package:bebecare/models/growth.dart';
import 'package:bebecare/widgets/growth_status_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const expectedAssets = <GrowthStatus, String>{
    GrowthStatus.underExpected: 'assets/images/baby_under_expected.png',
    GrowthStatus.healthyRange: 'assets/images/baby_within_expected.png',
    GrowthStatus.aboveExpected: 'assets/images/baby_above_expected.png',
  };

  const expectedSemanticLabels = <GrowthStatus, String>{
    GrowthStatus.underExpected:
        'Ilustração de bebê representando peso abaixo do esperado em relação ao tamanho',
    GrowthStatus.healthyRange:
        'Ilustração de bebê representando peso dentro do esperado em relação ao tamanho',
    GrowthStatus.aboveExpected:
        'Ilustração de bebê representando peso acima do esperado em relação ao tamanho',
  };

  for (final entry in expectedAssets.entries) {
    testWidgets('${entry.key.name} renders its approved baby illustration', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GrowthStatusCard(status: entry.key)),
        ),
      );

      final image = tester.widget<Image>(
        find.descendant(
          of: find.byType(GrowthStatusCard),
          matching: find.byType(Image),
        ),
      );
      final provider = image.image as AssetImage;

      expect(provider.assetName, entry.value);
    });

    testWidgets('${entry.key.name} exposes a status-specific semantic label', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GrowthStatusCard(status: entry.key)),
        ),
      );

      final image = tester.widget<Image>(
        find.descendant(
          of: find.byType(GrowthStatusCard),
          matching: find.byType(Image),
        ),
      );

      expect(image.semanticLabel, expectedSemanticLabels[entry.key]);
    });
  }

  testWidgets('all growth statuses render distinct baby illustrations', (
    tester,
  ) async {
    final renderedAssets = <String>{};

    for (final status in GrowthStatus.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GrowthStatusCard(status: status)),
        ),
      );

      final image = tester.widget<Image>(
        find.descendant(
          of: find.byType(GrowthStatusCard),
          matching: find.byType(Image),
        ),
      );
      renderedAssets.add((image.image as AssetImage).assetName);
    }

    expect(renderedAssets, hasLength(3));
  });
}
