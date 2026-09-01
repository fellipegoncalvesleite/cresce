import 'package:bebecare/data/baby_messages.dart';
import 'package:bebecare/data/baby_tips.dart';
import 'package:bebecare/data/vaccine_schedule.dart';
import 'package:bebecare/models/growth.dart';
import 'package:bebecare/screens/home_screen.dart';
import 'package:bebecare/services/app_state.dart';
import 'package:bebecare/services/stimulation_recommendations.dart';
import 'package:bebecare/services/vaccine_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final fixedNow = DateTime(2026, 9, 1, 12);
  final referenceDate = DateTime(2026, 9, 1);

  Future<AppState> demoState() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs: prefs, now: () => fixedNow);
    await state.load();
    return state;
  }

  Future<void> pumpHome(WidgetTester tester, AppState state) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(home: HomeScreen(referenceDate: referenceDate)),
      ),
    );
    await tester.pump();
  }

  testWidgets('demo Home shows the complete age-aware daily snapshot', (
    tester,
  ) async {
    final state = await demoState();
    final message = messageForDay(date: referenceDate, ageMonths: 8);
    final tip = tipForDay(date: referenceDate, ageMonths: 8);
    final daily = recommendationsForDay(date: referenceDate, ageMonths: 8);

    await pumpHome(tester, state);

    expect(find.text('Lia · 8 meses'), findsOneWidget);
    expect(find.text('Demonstração'), findsOneWidget);
    expect(find.text(message.text), findsOneWidget);
    expect(find.text('8,0 kg · 70 cm'), findsOneWidget);
    expect(find.text(GrowthStatus.healthyRange.label), findsOneWidget);
    expect(find.text('2 registros pendentes · 6 meses'), findsOneWidget);
    expect(find.text(daily.activity.title), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('home-calm-card')),
      300,
    );
    expect(find.text(daily.story!.title), findsOneWidget);
    expect(find.text(tip.text), findsOneWidget);
  });

  testWidgets('Home preferences hide vaccine and phase-tip sections', (
    tester,
  ) async {
    final state = await demoState();
    await state.setVaccineRemindersEnabled(false);
    await state.setWeeklyTipsEnabled(false);

    await pumpHome(tester, state);

    expect(find.byKey(const Key('home-vaccine-card')), findsNothing);
    expect(find.text('Dica para esta fase'), findsNothing);
  });

  testWidgets('Home cards select the existing destination tabs', (
    tester,
  ) async {
    final state = await demoState();
    await pumpHome(tester, state);

    await tester.tap(find.byKey(const Key('home-growth-card')));
    await tester.pump();
    expect(state.selectedIndex, 1);

    state.selectTab(0);
    await tester.pump();
    await tester.tap(find.byKey(const Key('home-vaccine-card')));
    await tester.pump();
    expect(state.selectedIndex, 2);

    state.selectTab(0);
    await tester.pump();
    await tester.tap(find.byKey(const Key('home-activity-card')));
    await tester.pump();
    expect(state.selectedIndex, 3);

    state.selectTab(0);
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('home-calm-card')),
      300,
    );
    await tester.tap(find.byKey(const Key('home-calm-card')));
    await tester.pump();
    expect(state.selectedIndex, 3);
  });

  testWidgets('Home vaccine summary follows CP2B next-milestone state', (
    tester,
  ) async {
    final state = await demoState();
    await state.setVaccineTaken('influenza_6', taken: true);
    await state.setVaccineTaken('covid_6', taken: true);
    final expected = nextRelevantVaccineMilestone(
      schedule: vaccineSchedule,
      babyAgeMonths: state.babyAgeMonths,
      recordFor: state.recordFor,
    );

    await pumpHome(tester, state);

    expect(expected?.ageLabel, '9 meses');
    expect(
      find.text('${expected!.vaccines.length} registros previstos · 9 meses'),
      findsOneWidget,
    );
  });

  testWidgets('personal Home has useful independent empty states', (
    tester,
  ) async {
    final state = await demoState();
    await state.startPersonalProfile();

    await pumpHome(tester, state);

    expect(find.text('Lia'), findsNothing);
    expect(find.textContaining('null meses'), findsNothing);
    expect(
      find.text(
        'Adicione a data de nascimento para personalizar as sugestões.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('Registre peso e tamanho para acompanhar o histórico.'),
      findsOneWidget,
    );
  });
}
