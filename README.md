# 🎮 Super Dash — a Mario-style platformer for Android

## 📥 Download & play now

**[⬇️ Download SuperDash-v1.0.0.apk](https://github.com/adeel40/Mario/raw/main/dist/SuperDash-v1.0.0.apk)** (46 MB)

1. Open the link above **on your Android phone** — the APK downloads.
2. Tap the downloaded file. If asked, allow "install from this source".
3. Tap **Install → Open**. The game runs in landscape with on-screen D-pad + JUMP.

> Signed with a debug key (fine for sideloading; re-sign with your own keystore for the Play Store).

---


A polished 2D side-scrolling platformer built with **Flutter + Flame**. Hand-painted
retro visuals (no image assets needed — everything is drawn with the canvas),
smooth physics, multiple levels, enemies, coins, sound hooks, and touch controls.

![genre](https://img.shields.io/badge/genre-platformer-red)
![engine](https://img.shields.io/badge/engine-Flame-blue)
![platform](https://img.shields.io/badge/platform-Android-green)

## ✨ Features

- **Full platformer physics** — running, jumping, gravity, terminal velocity, and
  axis-separated collision resolution against solid tiles.
- **3 hand-crafted levels** with increasing difficulty (Green Hills, Brick Caverns,
  Sky Fortress), each with its own time limit.
- **Hand-painted graphics** — animated hero (walk cycle, facing flip, jump),
  walking Goomba enemies with stomp squash, spinning coins, question blocks,
  bricks, pipes, a gradient parallax sky with rolling hills and drifting clouds,
  and a waving goal flag. All drawn with `Canvas` → crisp at any resolution.
- **Game loop & progression** — score, coins (100 coins = 1-up), lives, countdown
  timer with time bonus, enemy stomping, pits, ret/restart, level advance, and a
  win screen after the final level.
- **Sound system** — `AudioManager` wired for jump / coin / stomp / hurt / level-up
  / game-over SFX plus looping BGM. Missing files degrade gracefully to silence.
- **Mobile touch controls** — left/right D-pad + big JUMP button, plus pause.
- **Polished UI overlays** — main menu, HUD, pause, game-over, level-complete, win.

## 🗂 Project structure

```
super_dash/
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart                 # entry point (landscape + fullscreen)
│   ├── app.dart                  # MaterialApp + GameWidget + overlays
│   ├── game/
│   │   ├── super_dash_game.dart   # core FlameGame: world, camera, HUD, lifecycle
│   │   ├── constants.dart         # physics tuning + colour palette
│   │   ├── levels.dart            # tile-map level definitions
│   │   └── audio_manager.dart     # safe sound wrapper
│   ├── components/
│   │   ├── player.dart            # hero: input, physics, collisions, drawing
│   │   ├── enemy.dart             # Goomba: patrol, gravity, stomp
│   │   ├── blocks.dart            # ground / brick / question / pipe tiles
│   │   ├── coin.dart              # spinning collectible
│   │   └── background.dart        # parallax sky/hills/clouds + goal flag
│   └── ui/
│       └── overlays.dart          # all Flutter overlay screens + touch controls
├── assets/audio/                  # drop SFX/BGM here (see its README)
└── android/                       # Android platform config
```

## 🚀 Getting started

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.3+)
and the Android SDK (Android Studio makes this easy).

```bash
cd super_dash

# 1. Generate any remaining platform folders (icons, gradle wrapper, etc.)
#    This is safe: it fills in generated files without touching lib/ or the
#    android files already committed here.
flutter create . --project-name super_dash --org com.superdash --platforms=android

# 2. Fetch dependencies
flutter pub get

# 3a. Run on a connected device / emulator
flutter run

# 3b. …or build a release APK
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

Then `flutter install` (or copy the APK to your phone) to play.

## 🎯 How to play

- **Move:** left / right arrows (bottom-left)
- **Jump:** the red JUMP button (bottom-right)
- **Stomp** enemies by landing on top of them.
- **Collect coins** for points (100 coins → extra life).
- **Reach the flag** to clear the level. Beat all 3 to win!
- Touching an enemy from the side, falling in a pit, or running out of time costs
  a life.

## 🔊 Adding sound

Sound is optional and the game runs fine silently. To add audio, drop clips into
`assets/audio/` using the names listed in `assets/audio/README.md`, then
`flutter pub get` and rebuild.

## 🛠 Adding / editing levels

Levels are simple text tile-maps in `lib/game/levels.dart`. Each character is one
tile (`X` ground, `B` brick, `?` question block, `o` coin, `P`/`p` pipe,
`G` Goomba, `S` start, `F` flag). Add a new `LevelData` entry to `Levels.all` and
it appears automatically.

## 📝 Notes

This project was authored in an environment without the Flutter/Android toolchain,
so the code was written and structured for correctness but **not compiled here**.
Run `flutter analyze` after `flutter pub get` to confirm a clean analysis on your
machine, then `flutter run`.
