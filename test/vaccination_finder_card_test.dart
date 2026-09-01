import 'package:bebecare/widgets/vaccination_finder_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'finder exposes external search actions without location permission',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: VaccinationFinderCard()),
          ),
        ),
      );

      expect(find.text('Vacinação perto de você'), findsOneWidget);
      expect(find.text('Postos e UBS próximas'), findsOneWidget);
      expect(find.text('Ver no mapa'), findsOneWidget);
      expect(find.text('Cidade ou bairro'), findsOneWidget);
      expect(find.text('Buscar locais'), findsOneWidget);
      expect(find.text('Buscar campanhas'), findsOneWidget);
      expect(find.textContaining('Permitir localização'), findsNothing);
      expect(find.textContaining('Obtendo sua localização'), findsNothing);
    },
  );
}
