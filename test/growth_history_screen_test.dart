import 'package:bebecare/models/growth.dart';
import 'package:bebecare/screens/growth_screen.dart';
import 'package:bebecare/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final fixedNow = DateTime(2026, 9, 1, 12);

  Future<AppState> demoState() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs: prefs, now: () => fixedNow);
    await state.load();
    return state;
  }

  Future<void> pumpGrowth(WidgetTester tester, AppState state) async {
    await initializeDateFormatting('pt_BR', null);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: GrowthScreen()),
      ),
    );
    await tester.pump();
  }

  Finder mainScrollable() => find
      .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
      .first;

  testWidgets('demo Growth shows four recent records latest first', (
    tester,
  ) async {
    final state = await demoState();
    await pumpGrowth(tester, state);

    await tester.scrollUntilVisible(
      find.byKey(const Key('growth-history-0')),
      300,
      scrollable: mainScrollable(),
    );
    expect(find.text('Histórico recente'), findsOneWidget);
    final historyHeading = tester.widget<Semantics>(
      find.byKey(const Key('growth-history-heading')),
    );
    expect(historyHeading.properties.header, isTrue);
    expect(
      find.descendant(
        of: find.byKey(const Key('growth-history-0')),
        matching: find.text('8,0 kg · 70 cm'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('growth-history-0')),
        matching: find.textContaining('8 meses'),
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('growth-history-3')),
      300,
      scrollable: mainScrollable(),
    );
    for (var i = 0; i < 4; i++) {
      expect(find.byKey(Key('growth-history-$i')), findsOneWidget);
    }
  });

  testWidgets('a new measurement becomes the first visible history record', (
    tester,
  ) async {
    final state = await demoState();
    await pumpGrowth(tester, state);

    await state.addGrowthMeasurement(
      const GrowthMeasurement(weightKg: 9.1, lengthCm: 73, ageMonths: 9),
      recordedAt: DateTime(2026, 9, 1, 13),
    );
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('growth-history-0')),
      300,
      scrollable: mainScrollable(),
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('growth-history-0')),
        matching: find.text('9,1 kg · 73 cm'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('growth form resyncs when demo profile is cleared', (
    tester,
  ) async {
    final state = await demoState();
    await pumpGrowth(tester, state);

    await tester.scrollUntilVisible(
      find.byKey(const Key('growth-weight-field')),
      300,
      scrollable: mainScrollable(),
    );

    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('growth-weight-field')))
          .controller!
          .text,
      '8',
    );

    await state.startPersonalProfile();
    await tester.pump();

    expect(
      tester
          .widget<TextFormField>(find.byKey(const Key('growth-weight-field')))
          .controller!
          .text,
      isEmpty,
    );
  });
}
