import 'package:bebecare/screens/account_screen.dart';
import 'package:bebecare/screens/vaccine_screen.dart';
import 'package:bebecare/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('demo birth-date card redirects to Account without mutation', (
    tester,
  ) async {
    final fixedNow = DateTime(2026, 9, 1, 12);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs: prefs, now: () => fixedNow);
    await state.load();
    final originalBirthDate = state.birthDate;
    await initializeDateFormatting('pt_BR', null);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: VaccineScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('vaccine-birth-date-card')));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsNothing);
    expect(find.byType(AccountScreen), findsOneWidget);
    expect(state.selectedIndex, 0);
    expect(state.birthDate, originalBirthDate);
    expect(state.isDemoProfile, isTrue);
  });
}
