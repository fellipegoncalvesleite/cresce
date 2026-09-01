import 'package:bebecare/screens/vaccine_screen.dart';
import 'package:bebecare/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final fixedNow = DateTime(2026, 8, 31, 12);

  Future<AppState> stateWithPrefs(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs: prefs, now: () => fixedNow);
    await state.load();
    return state;
  }

  Future<void> pumpScreen(WidgetTester tester, AppState state) async {
    await initializeDateFormatting('pt_BR', null);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: VaccineScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('missing birth date shows age-calendar prompt instead of 0%', (
    tester,
  ) async {
    final state = await stateWithPrefs({'baby_name': 'Theo'});

    await pumpScreen(tester, state);

    expect(
      find.text(
        'Adicione a data de nascimento para acompanhar o calendário por idade.',
      ),
      findsOneWidget,
    );
    expect(find.text('0%'), findsNothing);
  });

  testWidgets(
    'demo Lia shows age-aware progress and oldest overdue milestone',
    (tester) async {
      final state = await stateWithPrefs({});

      await pumpScreen(tester, state);

      expect(find.text('Vacinas esperadas até agora'), findsOneWidget);
      expect(find.text('14 de 16 registradas'), findsOneWidget);
      expect(find.text('2 ainda não registradas'), findsOneWidget);
      expect(find.text('88%'), findsOneWidget);
      expect(find.text('Atenção ao calendário'), findsOneWidget);
      expect(
        find.text('2 vacinas ainda não registradas aos 6 meses'),
        findsOneWidget,
      );
      expect(find.text('Previstas para 6 meses'), findsOneWidget);
    },
  );
}
