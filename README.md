# Cresce

Cresce is a Portuguese Flutter prototype for organizing everyday baby care in one place: routines, growth records, vaccination references, age-appropriate activities, stories, sounds, and care notes. The current repository is a local/demo implementation, with no production backend or real authentication.

## PIBIC Jr / UFSJ context

This product was developed during a **PIBIC Jr. research/internship experience at the Universidade Federal de São João del-Rei (UFSJ)**. The prototype explores how a mobile app can bring several recurring parts of early-childhood care into one accessible interface instead of scattering them across separate notes, references, and tools.

My work represented in this repository is the **Flutter product implementation**: the app shell and shared state, growth-tracking experience, vaccination schedule and nearby-search flow, stories/songs/sound playback, account/settings experience, and interface polish. This repository describes that software contribution; it does not imply that every part of the broader PIBIC Jr. activity or surrounding research work was solely mine.

## What you can use

1. **Início** shows the daily overview and quick actions.
2. **Crescimento** saves weight and height records over time.
3. **Vacinas** shows the vaccination schedule and status.
4. **Estímulos** brings age-appropriate activities, stories, songs, and animal sounds.
5. **Conta** keeps the local profile, appearance settings, and demo login.
6. Light and dark mode are included through the shared app theme.

## Project structure

```text
lib/
  main.dart
  data/       static content (media, activities)
  models/     data models
  screens/    one file per screen + app shell with bottom navigation
  services/   sound player and other services
  theme/      color palettes and theming
  widgets/    shared widgets
```

## How to run

```bash
flutter pub get
flutter run
```

Asset credits are listed in [ASSETS_LICENSES.md](ASSETS_LICENSES.md).
