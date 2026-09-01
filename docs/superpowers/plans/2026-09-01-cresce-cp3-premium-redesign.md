# Cresce CP3 Premium Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign Cresce app-wide presentation into the approved Apple Health × premium maternity companion direction without changing any certified CP1/CP2 behavior.

**Architecture:** Keep `AppState`, recommendation selectors, growth mapping, vaccine logic, media data, SoundPlayer, legal substance, and demo lifecycle authoritative. Refactor only the presentation shell, theme/tokens, reusable visual primitives, and screen composition; Account becomes a pushed route while tab indices 0–3 remain stable. Accessibility and narrow/large-text layouts are first-class constraints.

**Tech Stack:** Flutter/Material 3, Provider, SharedPreferences, existing `intl`, `url_launcher`, and `audioplayers`; platform system fonts only.

**Spec:** Authoritative user-provided “CRESCE — CP3 PREMIUM VISUAL REDESIGN” brief supplied in this conversation on 2026-09-01.

## Global Constraints

- Start from clean `main` at `d0ff5822bccbf4cf1cc0e7ef8de8efaa378bfee6`.
- CP1 and CP2A/B/C/D semantics are frozen; presentation may change, logic may not be reimplemented or duplicated.
- No new backend/auth/AI/notifications/email/trackers/scoring/streaks/journal/photos/reports/WHO engine/minigames/sounds.
- Four tabs remain exactly 0 Home, 1 Growth, 2 Vaccines, 3 Estímulos; stale index 4 normalizes to Home.
- Remove Google Fonts/Nunito and any forced text-scaling clamp; do not bundle Apple fonts.
- Keep the three CP1 images and seven CP2C animal audio files byte-identical.
- Keep exactly five Estímulos categories and exactly three mini experiences.
- Use 160–240 ms restrained motion and respect `MediaQuery.disableAnimations`.
- Preserve all pre-CP3 behavioral tests and add CP3 regression coverage before production changes.
- Final gate requires analyzer/test/diff checks, rendered visual QA, independent reviews with Critical 0 / Important 0, commit, push, and remote `main` == local HEAD.

---

### Task 1: Lock CP3 behavior with failing regression tests

**Files:**
- Create: `test/cp3_redesign_test.dart`
- Modify: `test/demo_birth_date_safety_test.dart`

**Interfaces:**
- Consumes: `AppState.selectedIndex/selectTab`, `AppShell`, `HomeScreen`, `AccountScreen`, `BebeCareApp`.
- Produces: executable requirements for four-tab navigation, Account routing, stale-index safety, large text, and static source/dependency cleanup.

- [ ] **Step 1: Add CP3 tests that assert the new shell contract**

```dart
expect(find.descendant(of: find.byKey(const Key('app-bottom-navigation')), matching: find.text('Conta')), findsNothing);
expect(find.descendant(of: find.byKey(const Key('app-bottom-navigation')), matching: find.text('Início')), findsOneWidget);
state.selectTab(4);
expect(state.selectedIndex, 0);
```

- [ ] **Step 2: Add a profile-button routing test**

```dart
await tester.tap(find.byKey(const Key('top-level-profile-button')));
await tester.pumpAndSettle();
expect(find.byType(AccountScreen), findsOneWidget);
```

- [ ] **Step 3: Add static accessibility/font guards and large-text smoke tests**

```dart
expect(File('lib/screens/app_shell.dart').readAsStringSync(), isNot(contains('withClampedTextScaling')));
expect(File('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).map((f) => f.readAsStringSync()).join('\n'), isNot(contains('GoogleFonts')));
expect(File('pubspec.yaml').readAsStringSync(), isNot(contains('google_fonts:')));
```

- [ ] **Step 4: Update the demo vaccine birth-date presentation test**

The test must assert no date picker, no birth-date mutation, and that `AccountScreen` is pushed rather than asserting tab index 4.

- [ ] **Step 5: Run the focused tests and confirm RED for the intended CP3 gaps**

Run: `flutter test test/cp3_redesign_test.dart test/demo_birth_date_safety_test.dart`
Expected: FAIL because the old shell has five tabs, no profile route, retains the clamp/GoogleFonts, and demo Vaccine still selects tab 4.

---

### Task 2: Rebuild the shared design system and four-tab shell

**Files:**
- Modify: `lib/theme/app_tokens.dart`
- Modify: `lib/theme/app_theme.dart`
- Modify: `lib/widgets/app_card.dart`
- Modify: `lib/widgets/section_header.dart`
- Create: `lib/widgets/top_level_page_header.dart`
- Modify: `lib/services/app_state.dart`
- Modify: `lib/screens/app_shell.dart`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`

**Interfaces:**
- Consumes: existing `AppColors` call sites and `AppState.selectTab` callers.
- Produces: warm palettes, platform typography, quiet surfaces, reusable top-level header/profile route, and normalized four-tab shell.

- [ ] **Step 1: Normalize the tab index without shifting 1/2/3**

```dart
static const int tabCount = 4;
static int normalizeTabIndex(int index) => index >= 0 && index < tabCount ? index : 0;
int get selectedIndex => normalizeTabIndex(_selectedIndex);
void selectTab(int index) {
  final normalized = normalizeTabIndex(index);
  if (_selectedIndex == normalized) return;
  _selectedIndex = normalized;
  notifyListeners();
}
```

- [ ] **Step 2: Replace light/dark tokens with the approved warm off-white/eucalyptus and neutral-charcoal families**

Add a grouped-surface token and use card radius 22 / field radius 16 while retaining all semantic status token names.

- [ ] **Step 3: Remove Google Fonts and define the platform text hierarchy in `ThemeData`**

Use 400 body, 500/600 emphasis, 700 major headings/actions; no bundled font family and no `FontWeight.w800` in the theme.

- [ ] **Step 4: Make cards/fields/buttons quiet by default**

`AppCard` has no visible border unless explicitly requested; fields use grouped fill with transparent rest border and eucalyptus focus outline; controls retain at least 44 logical pixels.

- [ ] **Step 5: Add `TopLevelPageHeader` with a circular 48×48 profile button**

The button uses key `top-level-profile-button`, tooltip `Abrir perfil`, and pushes `AccountScreen` with `MaterialPageRoute`.

- [ ] **Step 6: Replace the five-destination shell with a four-destination large-text-safe bottom bar**

Use key `app-bottom-navigation`; selected icon/label eucalyptus, unselected neutral; no selected Material pill; labels scale naturally and the bar can scroll horizontally at large text instead of clipping.

- [ ] **Step 7: Remove `google_fonts` from dependencies and refresh lockfile**

Run: `flutter pub get`

- [ ] **Step 8: Run focused CP3 shell/static tests and make them GREEN**

Run: `flutter test test/cp3_redesign_test.dart`
Expected: PASS for shell/font/static tests before screen-specific assertions are added.

---

### Task 3: Recompose Home around hero, Hoje, Saúde, tip, and calm content

**Files:**
- Modify: `lib/screens/home_screen.dart`
- Test: `test/home_screen_test.dart`
- Test: `test/cp3_redesign_test.dart`

**Interfaces:**
- Consumes: unchanged `messageForDay`, `recommendationsForDay`, `tipForDay`, `nextRelevantVaccineMilestone`, latest growth/status, and preference flags.
- Produces: premium Home composition while preserving keys/text and tab actions 1/2/3.

- [ ] **Step 1: Add/retain tests for deterministic Lia data and Home actions at 1.6×/2.0× text scale**
- [ ] **Step 2: Verify the new large-text Home test fails on the old composition if it overflows**
- [ ] **Step 3: Replace the AppBar dashboard with `TopLevelPageHeader(title: 'Cresce')` and a hero containing identity, restrained demo label, CP1 illustration when available, and the unchanged daily message**
- [ ] **Step 4: Put `home-activity-card` first as the strongest feature surface**
- [ ] **Step 5: Group `home-growth-card` and `home-vaccine-card` inside one Saúde surface with internal separation**
- [ ] **Step 6: Render tip and `home-calm-card` as quieter lower sections**
- [ ] **Step 7: Route `home-birth-cta` and `home-caregiver-cta` to Account without `selectTab(4)` and retain personal empty-state copy**
- [ ] **Step 8: Run Home tests**

Run: `flutter test test/home_screen_test.dart test/cp3_redesign_test.dart`

---

### Task 4: Recompose Growth and constrain motion/responsiveness

**Files:**
- Modify: `lib/screens/growth_screen.dart`
- Modify: `lib/widgets/growth_status_card.dart`
- Test: `test/growth_history_screen_test.dart`
- Test: `test/growth_status_card_test.dart`

**Interfaces:**
- Consumes: unchanged `GrowthStatus` asset/semantic mapping and append-only `setMeasurement` behavior.
- Produces: status-first Growth screen, separate quiet measurement summary, compact latest-first history, secondary form, 160–240 ms reduced-motion-safe animation.

- [ ] **Step 1: Preserve exact mapping/semantic tests and latest-first history tests**
- [ ] **Step 2: Add top-level profile header and promote the 120–150 px CP1 illustration/status hero**
- [ ] **Step 3: Separate latest measurements from the status hero and demote BMI metadata**
- [ ] **Step 4: Keep history in one grouped surface with internal dividers and heading semantics**
- [ ] **Step 5: Make the measurement form responsive: two columns only when width/text scale permits, otherwise stack fields**
- [ ] **Step 6: Replace 650 ms overshooting growth animation with ~220 ms fade/subtle scale using a non-overshooting curve and `disableAnimations`**
- [ ] **Step 7: Run Growth tests**

Run: `flutter test test/growth_status_card_test.dart test/growth_history_screen_test.dart`

---

### Task 5: Recompose Vaccines into health summary + chronological grouped calendar

**Files:**
- Modify: `lib/screens/vaccine_screen.dart`
- Modify: `lib/widgets/vaccine_milestone_card.dart`
- Modify: `lib/widgets/vaccination_finder_card.dart`
- Test: `test/vaccine_screen_test.dart`
- Test: `test/demo_birth_date_safety_test.dart`

**Interfaces:**
- Consumes: unchanged vaccine progress/next-milestone/status selectors, record mutation, and `ExternalSearch` GPS-free behavior.
- Produces: linear progress, prominent next/overdue state, profile context, grouped chronological calendar, secondary finder.

- [ ] **Step 1: Keep exact CP2B progress/next tests and change demo birth route expectation to Account**
- [ ] **Step 2: Replace circular donut with text + `LinearProgressIndicator` while retaining `14 de 16 registradas`, overdue copy, and `88%`**
- [ ] **Step 3: Make next/overdue state more prominent through restrained semantic tint + icon/text**
- [ ] **Step 4: Render vaccine milestones inside one chronological grouped/timeline surface with internal separators rather than bordered cards**
- [ ] **Step 5: Move the GPS-free finder after the calendar and keep all URLs/actions unchanged**
- [ ] **Step 6: Run Vaccine and external-search tests**

Run: `flutter test test/vaccine_screen_test.dart test/demo_birth_date_safety_test.dart test/vaccination_finder_card_test.dart test/external_search_test.dart`

---

### Task 6: Restyle Estímulos, sounds, and exactly three mini experiences

**Files:**
- Modify: `lib/screens/estimulando_screen.dart`
- Modify: `lib/widgets/animal_sound_card.dart`
- Modify: `lib/widgets/story_card.dart`
- Modify: `lib/widgets/song_card.dart`
- Modify: `lib/screens/peekaboo_activity_screen.dart`
- Modify: `lib/screens/animal_sound_game_screen.dart`
- Modify: `lib/screens/shapes_activity_screen.dart`
- Modify: `lib/screens/story_reader_screen.dart`
- Test: `test/stimulation_ui_test.dart`
- Test: `test/stimulation_recommendations_test.dart`

**Interfaces:**
- Consumes: unchanged 27 activities, five categories, recommendation selectors, seven `animalSounds`, shared playback controller, stories/songs, and three `BabyActivityExperience` enum values.
- Produces: editorial category navigation, curated feed, calm sound cards, responsive mini experiences.

- [ ] **Step 1: Preserve tests proving five categories, Para hoje default, shared playback success/failure/stop, and the three experiences**
- [ ] **Step 2: Use the shared top-level header above a light scrollable TabBar with understated indicator**
- [ ] **Step 3: Lead Para hoje with the activity; replace loud chips with quiet icon/metadata treatment**
- [ ] **Step 4: Make sound layout responsive; enlarge emoji and Play/Stop affordance; make source/license info at least 44×44 with tooltip**
- [ ] **Step 5: Restyle story/song surfaces without changing origin/search/licensing/content behavior**
- [ ] **Step 6: Set Peekaboo transition to ~200 ms fade/subtle scale and honor disabled animations**
- [ ] **Step 7: Make animal-game listening state textual/iconic, not color-only, and make Shapes choices wrap/adapt at 320 px and large text**
- [ ] **Step 8: Make story-reader metadata wrap instead of overflow**
- [ ] **Step 9: Run stimulation/media tests**

Run: `flutter test test/stimulation_ui_test.dart test/stimulation_recommendations_test.dart`

---

### Task 7: Refine Account, Settings, and Legal presentation

**Files:**
- Modify: `lib/screens/account_screen.dart`
- Modify: `lib/screens/settings_screen.dart`
- Modify: `lib/screens/legal_document_screen.dart`
- Test: `test/account_showcase_test.dart`
- Test: `test/settings_showcase_test.dart`

**Interfaces:**
- Consumes: unchanged demo→personal confirmation/action, controller resync, local login semantics, reset-demo action, theme/preferences, and legal section content.
- Produces: pushed profile page, native grouped preferences, readable unboxed legal sections.

- [ ] **Step 1: Keep all existing demo lifecycle/controller/reset/legal tests**
- [ ] **Step 2: Make Account a compact pushed profile page with baby identity/details, explicit demo/personal state, family profile, accurate local-account language, and a Settings row**
- [ ] **Step 3: Keep “Começar com meu bebê” visually separate and retain the existing confirmation path exactly**
- [ ] **Step 4: Convert Settings to compact grouped preference rows for Aparência/Página inicial/Demonstração/Sobre**
- [ ] **Step 5: Remove decorative card-per-section framing from legal documents while retaining every `Semantics(header: true)`**
- [ ] **Step 6: Run Account/Settings tests**

Run: `flutter test test/account_showcase_test.dart test/settings_showcase_test.dart`

---

### Task 8: Stale-style cleanup, full automated verification, and frozen-state checks

**Files:**
- Review all changed production/test files.

**Interfaces:**
- Produces: clean CP3 candidate suitable for rendered QA/review.

- [ ] **Step 1: Format every changed Dart file**

Run: `dart format <changed .dart files>`

- [ ] **Step 2: Scan stale style markers**

Run: `rg -n "GoogleFonts|Nunito|FontWeight\\.w800|withClampedTextScaling|selectTab\\(4\\)|deep teal|five tabs|BorderSide\\(color: AppColors\\.hairline\\)" lib pubspec.yaml`

Review each remaining hit; only semantically justified borders/rare weights may remain.

- [ ] **Step 3: Run complete verification**

Run: `flutter analyze && flutter test && git diff --check`
Expected: analyzer “No issues found!”, all tests pass, diff check clean.

- [ ] **Step 4: Recompute frozen asset hashes and compare byte-for-byte with the recorded CP2D baseline**

Run: `shasum -a 256 assets/images/baby_under_expected.png assets/images/baby_within_expected.png assets/images/baby_above_expected.png assets/audio/animals/*`

---

### Task 9: Rendered visual QA, independent reviews, commit, push, and remote verification

**Files:**
- No persistent QA screenshot files.

**Interfaces:**
- Produces: final certified and pushed CP3 state.

- [ ] **Step 1: Render and inspect LIGHT Home/Growth/Vaccines/Estímulos/Account, DARK Home/Growth/Estímulos, LARGE TEXT AppShell/Home, plus Settings/Privacy/one mini experience**

Use available Flutter/macOS screenshot tooling; screenshots are temporary and never committed. Check 320–360 px narrow behavior and 1.6×/2.0× text for clipping/overlap.

- [ ] **Step 2: Obtain READ-ONLY Reviewer A**

Focus: typography, palette, surfaces, navigation, text scaling, touch targets, semantics, dark mode.

- [ ] **Step 3: Obtain READ-ONLY Reviewer B**

Focus: Home/Growth/Vaccines/Estímulos/Account/Settings visual consistency and stale generic Material styling.

- [ ] **Step 4: Obtain READ-ONLY Reviewer C**

Focus: CP1/CP2 frozen behavior, indices, demo lifecycle, vaccine/recommendation reuse, no scope leakage.

- [ ] **Step 5: For every Critical/Important finding, add a reproducing test when applicable, fix through TDD, and re-run full verification**

- [ ] **Step 6: Request fresh final READ-ONLY re-review and require `Critical 0, Important 0`**

- [ ] **Step 7: Create the terminal CP3 commit**

Run: `git add <scoped files> && git commit -m "feat: redesign Cresce premium experience"`

- [ ] **Step 8: Push and verify remote main**

Run: `git push origin HEAD && test "$(git rev-parse HEAD)" = "$(git ls-remote origin refs/heads/main | awk '{print $1}')"`

If push fails or remote SHA differs, report `CP3 RESULT: BLOCKED` with exact error.
