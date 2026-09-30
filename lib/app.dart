import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game/super_dash_game.dart';
import 'ui/overlays.dart';

/// Root application widget. Hosts the Flame [GameWidget] and wires up all of
/// the Flutter overlays (main menu, HUD, pause, game-over, level-complete).
class SuperDashApp extends StatelessWidget {
  const SuperDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'monospace',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE52521)),
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final SuperDashGame _game;

  @override
  void initState() {
    super.initState();
    _game = SuperDashGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget<SuperDashGame>(
        game: _game,
        overlayBuilderMap: <String, Widget Function(BuildContext, SuperDashGame)>{
          Overlays.mainMenu: (_, g) => MainMenuOverlay(game: g),
          Overlays.hud: (_, g) => HudOverlay(game: g),
          Overlays.controls: (_, g) => ControlsOverlay(game: g),
          Overlays.pause: (_, g) => PauseOverlay(game: g),
          Overlays.gameOver: (_, g) => GameOverOverlay(game: g),
          Overlays.levelComplete: (_, g) => LevelCompleteOverlay(game: g),
          Overlays.gameWon: (_, g) => GameWonOverlay(game: g),
        },
        initialActiveOverlays: const <String>[Overlays.mainMenu],
      ),
    );
  }
}
