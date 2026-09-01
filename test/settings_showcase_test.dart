import 'package:bebecare/screens/settings_screen.dart';
import 'package:bebecare/screens/home_screen.dart';
import 'package:bebecare/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Future<void> pumpSettings(WidgetTester tester, AppState state) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
  }

  Finder mainScrollable() => find
      .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
      .first;

  testWidgets('Settings exposes only functional Home preferences', (
    tester,
  ) async {
    final state = await demoState();
    await pumpSettings(tester, state);

    expect(find.text('Página inicial'), findsOneWidget);
    expect(find.text('Lembretes de vacina'), findsOneWidget);
    expect(find.text('Dicas para esta fase'), findsOneWidget);
    expect(find.text('Novidades por e-mail'), findsNothing);
    expect(find.text('Notificações'), findsNothing);
  });

  testWidgets('Settings theme choices keep at least a 44x44 touch target', (
    tester,
  ) async {
    final state = await demoState();
    await pumpSettings(tester, state);

    for (final label in ['Padrão do sistema', 'Claro', 'Escuro']) {
      final target = find
          .ancestor(of: find.text(label), matching: find.byType(InkWell))
          .first;
      final size = tester.getSize(target);
      expect(size.width, greaterThanOrEqualTo(44), reason: label);
      expect(size.height, greaterThanOrEqualTo(44), reason: label);
    }
  });

  testWidgets('Settings Home switches directly change Home content', (
    tester,
  ) async {
    final state = await demoState();
    await pumpSettings(tester, state);

    await tester.tap(find.text('Lembretes de vacina'));
    await tester.pump();
    await tester.tap(find.text('Dicas para esta fase'));
    await tester.pump();

    expect(state.vaccineRemindersEnabled, isFalse);
    expect(state.weeklyTipsEnabled, isFalse);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          home: HomeScreen(referenceDate: DateTime(2026, 9, 1)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('home-vaccine-card')), findsNothing);
    expect(find.text('Dica para esta fase'), findsNothing);
  });

  testWidgets('Terms and Privacy contain real local information', (
    tester,
  ) async {
    final state = await demoState();
    await pumpSettings(tester, state);

    await tester.scrollUntilVisible(
      find.text('Termos de uso'),
      300,
      scrollable: mainScrollable(),
    );
    await tester.tap(find.text('Termos de uso'));
    await tester.pumpAndSettle();
    final legalHeading = tester.widget<Semantics>(
      find.byKey(const Key('legal-section-heading-0')),
    );
    expect(legalHeading.properties.header, isTrue);
    expect(find.textContaining('não substitui diagnóstico'), findsOneWidget);
    expect(find.textContaining('supervisão de um responsável'), findsOneWidget);
    expect(find.textContaining('em breve'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Política de privacidade'),
      300,
      scrollable: mainScrollable(),
    );
    await tester.tap(find.text('Política de privacidade'));
    await tester.pumpAndSettle();
    expect(find.textContaining('armazenados localmente'), findsOneWidget);
    expect(
      find.textContaining('não solicita sua localização GPS'),
      findsOneWidget,
    );
    expect(find.textContaining('YouTube'), findsOneWidget);
    expect(find.textContaining('Spotify'), findsOneWidget);
    expect(find.textContaining('em breve'), findsNothing);
  });

  testWidgets(
    'Settings can restore the demo without changing Home preferences',
    (tester) async {
      final state = await demoState();
      await state.setVaccineRemindersEnabled(false);
      await state.setWeeklyTipsEnabled(false);
      await state.startPersonalProfile();
      await pumpSettings(tester, state);

      await tester.scrollUntilVisible(
        find.byKey(const Key('reset-demo-data')),
        300,
        scrollable: mainScrollable(),
      );
      await tester.ensureVisible(find.byKey(const Key('reset-demo-data')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('reset-demo-data')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-reset-demo-data')));
      await tester.pumpAndSettle();

      expect(state.isDemoProfile, isTrue);
      expect(state.babyName, 'Lia');
      expect(state.growthHistory, hasLength(4));
      expect(state.recordFor('bcg_0'), isNotNull);
      expect(state.vaccineRemindersEnabled, isFalse);
      expect(state.weeklyTipsEnabled, isFalse);
    },
  );
}
