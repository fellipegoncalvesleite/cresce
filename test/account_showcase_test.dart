import 'package:bebecare/screens/account_screen.dart';
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

  Future<void> pumpAccount(WidgetTester tester, AppState state) async {
    await initializeDateFormatting('pt_BR', null);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: AccountScreen()),
      ),
    );
    await tester.pump();
  }

  Finder mainScrollable() => find
      .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
      .first;

  testWidgets('Account presents coherent demo baby information', (
    tester,
  ) async {
    final state = await demoState();
    await pumpAccount(tester, state);

    expect(find.text('Perfil de demonstração'), findsOneWidget);
    expect(find.text('Lia · 8 meses'), findsOneWidget);
    expect(find.textContaining('Nascimento:'), findsOneWidget);
    expect(find.text('8,0 kg · 70 cm'), findsOneWidget);
    expect(find.text('Começar com meu bebê'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Conta local de demonstração'),
      300,
      scrollable: mainScrollable(),
    );
    expect(find.text('Conta local de demonstração'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('account-baby-name-field')),
      300,
      scrollable: mainScrollable(),
    );
    final nameField = tester.widget<TextField>(
      find.byKey(const Key('account-baby-name-field')),
    );
    expect(nameField.enabled, isFalse);
  });

  testWidgets('confirmed demo transition enables a clean personal profile', (
    tester,
  ) async {
    final state = await demoState();
    await pumpAccount(tester, state);

    await tester.tap(find.byKey(const Key('start-personal-profile')));
    await tester.pumpAndSettle();
    expect(find.textContaining('incluindo medidas e vacinas'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-start-personal-profile')));
    await tester.pumpAndSettle();

    expect(state.isDemoProfile, isFalse);
    expect(find.text('Perfil pessoal'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('account-baby-name-field')),
      300,
      scrollable: mainScrollable(),
    );
    final nameField = tester.widget<TextField>(
      find.byKey(const Key('account-baby-name-field')),
    );
    expect(nameField.enabled, isTrue);
    expect(nameField.controller!.text, isEmpty);
  });

  testWidgets('personal profile exposes birth-date editing', (tester) async {
    final state = await demoState();
    await state.startPersonalProfile();
    await pumpAccount(tester, state);

    await tester.scrollUntilVisible(
      find.byKey(const Key('account-birth-date-card')),
      300,
      scrollable: mainScrollable(),
    );
    expect(find.text('Adicionar data de nascimento'), findsOneWidget);
    await tester.tap(find.byKey(const Key('account-birth-date-card')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });

  testWidgets('Account controllers resync when profile lifecycle changes', (
    tester,
  ) async {
    final state = await demoState();
    await pumpAccount(tester, state);

    await tester.scrollUntilVisible(
      find.byKey(const Key('account-baby-name-field')),
      300,
      scrollable: mainScrollable(),
    );

    await state.startPersonalProfile();
    await tester.pump();

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('account-baby-name-field')))
          .controller!
          .text,
      isEmpty,
    );

    await state.resetDemoData();
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('account-baby-name-field')))
          .controller!
          .text,
      'Lia',
    );
  });
}
