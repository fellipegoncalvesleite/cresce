import 'package:bebecare/data/media_data.dart';
import 'package:bebecare/screens/animal_sound_game_screen.dart';
import 'package:bebecare/screens/estimulando_screen.dart';
import 'package:bebecare/screens/peekaboo_activity_screen.dart';
import 'package:bebecare/screens/shapes_activity_screen.dart';
import 'package:bebecare/services/app_state.dart';
import 'package:bebecare/services/sound_player.dart';
import 'package:bebecare/widgets/animal_sound_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSoundPlayer implements SoundPlaybackController {
  @override
  final ValueNotifier<String?> playing = ValueNotifier<String?>(null);

  final List<String> toggled = [];
  bool failNext = false;

  @override
  Future<void> toggle(String assetPath) async {
    if (failNext) {
      failNext = false;
      throw StateError('fake playback failure');
    }
    toggled.add(assetPath);
    playing.value = playing.value == assetPath ? null : assetPath;
  }

  @override
  Future<void> stop() async {
    playing.value = null;
  }
}

void main() {
  Future<AppState> demoState() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs: prefs, now: () => DateTime(2026, 9, 1, 12));
    await state.load();
    return state;
  }

  testWidgets('AnimalSoundCard exposes Tocar and Parar with injected player', (
    tester,
  ) async {
    final player = FakeSoundPlayer();
    final sound = animalSounds.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalSoundCard(sound: sound, player: player),
        ),
      ),
    );

    expect(find.text('Tocar'), findsOneWidget);
    await tester.tap(find.byType(AnimalSoundCard));
    await tester.pump();

    expect(player.toggled, [sound.assetPath]);
    expect(find.text('Parar'), findsOneWidget);

    await tester.tap(find.byType(AnimalSoundCard));
    await tester.pump();
    expect(player.playing.value, isNull);
    expect(find.text('Tocar'), findsOneWidget);
  });

  testWidgets('AnimalSoundCard reports playback failure without real audio', (
    tester,
  ) async {
    final player = FakeSoundPlayer()..failNext = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimalSoundCard(sound: animalSounds.first, player: player),
        ),
      ),
    );

    await tester.tap(find.byType(AnimalSoundCard));
    await tester.pump();

    expect(find.text('Não foi possível tocar o som.'), findsOneWidget);
  });

  testWidgets('Cadê Achou can hide reveal and reset', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PeekabooActivityScreen()));

    expect(find.byKey(const Key('peekaboo-hidden')), findsOneWidget);
    expect(find.byKey(const Key('peekaboo-revealed')), findsNothing);

    await tester.tap(find.byKey(const Key('peekaboo-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('peekaboo-revealed')), findsOneWidget);
    expect(find.text('Achou!'), findsOneWidget);

    await tester.tap(find.byKey(const Key('peekaboo-toggle')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('peekaboo-hidden')), findsOneWidget);
  });

  testWidgets('animal sound mini experience uses shared animal sound data', (
    tester,
  ) async {
    final player = FakeSoundPlayer();

    await tester.pumpWidget(
      MaterialApp(home: AnimalSoundGameScreen(player: player)),
    );

    final sound = animalSounds.first;
    expect(find.text(sound.name), findsOneWidget);
    await tester.tap(find.byKey(Key('animal-game-${sound.id}')));
    await tester.pump();

    expect(player.toggled, [sound.assetPath]);
    expect(find.text('Ouvindo ${sound.name}'), findsOneWidget);
  });

  testWidgets('shapes activity accepts correct choice after an incorrect one', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ShapesActivityScreen()));

    expect(find.textContaining('círculo'), findsOneWidget);
    await tester.tap(find.byKey(const Key('shape-square')));
    await tester.pump();
    expect(find.text('Tente outra forma junto.'), findsOneWidget);
    expect(find.textContaining('círculo'), findsOneWidget);

    await tester.tap(find.byKey(const Key('shape-circle')));
    await tester.pump();
    expect(find.text('Encontrou!'), findsOneWidget);
  });

  testWidgets('Estímulos defaults to Para hoje with Lia recommendations', (
    tester,
  ) async {
    final state = await demoState();
    final player = FakeSoundPlayer();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          home: EstimulandoScreen(
            referenceDate: DateTime(2026, 9, 1),
            soundPlayer: player,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Para hoje'), findsWidgets);
    expect(find.text('Brincadeiras'), findsOneWidget);
    expect(find.text('Sons'), findsOneWidget);
    expect(find.text('Histórias'), findsOneWidget);
    expect(find.text('Cantigas'), findsOneWidget);
    expect(find.text('Para Lia · 8 meses'), findsOneWidget);
    expect(find.text('Atividade de hoje'), findsOneWidget);
    expect(find.text('História para hoje'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('stimulation-Para hoje')),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(find.text('Som para explorar'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('stimulation-Para hoje')),
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cantiga para hoje'), findsOneWidget);
  });

  testWidgets(
    'all Estímulos categories are reachable and story reader remains',
    (tester) async {
      final state = await demoState();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: state,
          child: MaterialApp(
            home: EstimulandoScreen(referenceDate: DateTime(2026, 9, 1)),
          ),
        ),
      );
      await tester.pump();

      for (final tab in ['Brincadeiras', 'Sons', 'Histórias', 'Cantigas']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();
        expect(find.byKey(Key('stimulation-$tab')), findsOneWidget);
      }

      await tester.tap(find.text('Histórias'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ler').first);
      await tester.pumpAndSettle();
      expect(find.text('✿ Fim ✿'), findsOneWidget);
    },
  );
}
