import 'dart:io';

import 'package:bebecare/main.dart';
import 'package:bebecare/screens/account_screen.dart';
import 'package:bebecare/screens/app_shell.dart';
import 'package:bebecare/services/app_state.dart';
import 'package:bebecare/theme/app_theme.dart';
import 'package:bebecare/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  final fixedNow = DateTime(2026, 9, 1, 12);

  Future<AppState> demoState() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs: prefs, now: () => fixedNow);
    await state.load();
    return state;
  }

  Future<void> pumpShell(
    WidgetTester tester,
    AppState state, {
    double textScale = 1,
    Size size = const Size(360, 800),
  }) async {
    AppColors.apply(Brightness.light);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) {
            final media = MediaQuery.of(
              context,
            ).copyWith(size: size, textScaler: TextScaler.linear(textScale));
            return MediaQuery(data: media, child: child!);
          },
          home: const AppShell(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('bottom navigation exposes exactly the four CP3 destinations', (
    tester,
  ) async {
    final state = await demoState();
    await pumpShell(tester, state);

    final nav = find.byKey(const Key('app-bottom-navigation'));
    expect(nav, findsOneWidget);
    expect(
      find.descendant(of: nav, matching: find.text('Início')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nav, matching: find.text('Crescimento')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nav, matching: find.text('Vacinas')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nav, matching: find.text('Estímulos')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: nav, matching: find.text('Conta')),
      findsNothing,
    );
    for (var i = 0; i < 4; i++) {
      expect(find.byKey(Key('bottom-nav-$i')), findsOneWidget);
    }
    expect(find.byKey(const Key('bottom-nav-4')), findsNothing);
  });

  test('stale or invalid tab indices normalize safely to Home', () async {
    final state = await demoState();

    state.selectTab(1);
    expect(state.selectedIndex, 1);
    state.selectTab(2);
    expect(state.selectedIndex, 2);
    state.selectTab(3);
    expect(state.selectedIndex, 3);

    state.selectTab(4);
    expect(state.selectedIndex, 0);
    state.selectTab(-1);
    expect(state.selectedIndex, 0);
  });

  testWidgets(
    'top-level profile button pushes Account without becoming a tab',
    (tester) async {
      final state = await demoState();
      await pumpShell(tester, state);

      final profile = find.byKey(const Key('top-level-profile-button'));
      expect(profile, findsOneWidget);
      await tester.tap(profile);
      await tester.pumpAndSettle();

      expect(find.byType(AccountScreen), findsOneWidget);
      expect(state.selectedIndex, 0);
    },
  );

  testWidgets('AppShell remains usable at increased text scale', (
    tester,
  ) async {
    for (final scale in [1.0, 1.3, 1.6, 2.0]) {
      final state = await demoState();
      await pumpShell(
        tester,
        state,
        textScale: scale,
        size: const Size(320, 700),
      );
      expect(tester.takeException(), isNull, reason: 'text scale $scale');
      expect(find.text('Início'), findsOneWidget);
      expect(find.text('Crescimento'), findsWidgets);
      expect(find.text('Vacinas'), findsWidgets);
      expect(find.text('Estímulos'), findsOneWidget);
    }
  });

  testWidgets('Home builds at 1.6x and 2.0x without critical overflow', (
    tester,
  ) async {
    for (final scale in [1.6, 2.0]) {
      final state = await demoState();
      await pumpShell(
        tester,
        state,
        textScale: scale,
        size: const Size(360, 800),
      );
      expect(tester.takeException(), isNull, reason: 'Home text scale $scale');
      expect(find.textContaining('Lia · 8 meses'), findsOneWidget);
    }
  });

  testWidgets('light and dark app roots build without exceptions', (
    tester,
  ) async {
    final state = await demoState();
    await tester.pumpWidget(BebeCareApp(appState: state));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await state.setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      Theme.of(tester.element(find.byType(AppShell))).brightness,
      Brightness.dark,
    );
  });

  testWidgets(
    'dark Home Growth Vaccines and Estímulos build without exceptions',
    (tester) async {
      final state = await demoState();
      await state.setThemeMode(ThemeMode.dark);
      await tester.pumpWidget(BebeCareApp(appState: state));
      await tester.pump();

      for (final index in [0, 1, 2, 3]) {
        state.selectTab(index);
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'dark tab $index');
        expect(state.selectedIndex, index);
      }
    },
  );

  test('production source contains no text-scale clamp or Google Fonts', () {
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      expect(
        source.contains('withClampedTextScaling'),
        isFalse,
        reason: file.path,
      );
      expect(source.contains('GoogleFonts'), isFalse, reason: file.path);
      expect(source.contains('google_fonts'), isFalse, reason: file.path);
    }
    expect(
      File('pubspec.yaml').readAsStringSync().contains('google_fonts:'),
      isFalse,
    );
  });
}
