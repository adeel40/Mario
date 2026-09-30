import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../components/background.dart';
import '../components/blocks.dart';
import '../components/coin.dart';
import '../components/enemy.dart';
import '../components/player.dart';
import '../ui/overlays.dart';
import 'audio_manager.dart';
import 'constants.dart';
import 'levels.dart';

enum GameStatus { menu, playing, paused, dead, levelComplete, gameOver, won }

/// The main Flame game. Owns the world state, camera, HUD values and the
/// level lifecycle (load / restart / advance).
class SuperDashGame extends FlameGame {
  final AudioManager audio = AudioManager();

  // --- Reactive HUD state (widgets listen to these) ---
  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> coins = ValueNotifier<int>(0);
  final ValueNotifier<int> lives = ValueNotifier<int>(GameConfig.startingLives);
  final ValueNotifier<int> timeLeft = ValueNotifier<int>(0);
  final ValueNotifier<int> levelIndex = ValueNotifier<int>(0);

  GameStatus status = GameStatus.menu;

  late Player player;
  final List<GameBlock> solidBlocks = <GameBlock>[];

  double cameraX = 0;
  double elapsed = 0;
  double _timeAccumulator = 0;

  LevelData get level => Levels.all[levelIndex.value];

  @override
  Future<void> onLoad() async {
    await audio.preload();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  void startGame() {
    score.value = 0;
    coins.value = 0;
    lives.value = GameConfig.startingLives;
    levelIndex.value = 0;
    _loadLevel();
    audio.startMusic();
  }

  void _loadLevel() {
    // Clear previous world contents.
    for (final Component c in children.toList()) {
      if (c is Player ||
          c is Block ||
          c is Coin ||
          c is Goomba ||
          c is ParallaxBackground ||
          c is GoalFlag) {
        c.removeFromParent();
      }
    }
    solidBlocks.clear();
    cameraX = 0;
    elapsed = 0;
    _timeAccumulator = 0;
    timeLeft.value = level.timeLimit;

    final double worldWidth = level.columns * GameConfig.tileSize;
    final double worldHeight = level.rowCount * GameConfig.tileSize;

    add(ParallaxBackground(worldWidth: worldWidth, worldHeight: worldHeight));

    Vector2 startPos = Vector2(GameConfig.tileSize, GameConfig.tileSize);

    for (int row = 0; row < level.rowCount; row++) {
      final String line = level.rows[row];
      for (int col = 0; col < line.length; col++) {
        final Vector2 pos =
            Vector2(col * GameConfig.tileSize, row * GameConfig.tileSize);
        switch (line[col]) {
          case 'X':
            final bool grass = row == 0 || _isEmpty(row - 1, col);
            _addSolid(GroundBlock(position: pos, hasGrassTop: grass));
            break;
          case 'B':
            _addSolid(BrickBlock(position: pos));
            break;
          case '?':
            _addSolid(QuestionBlock(position: pos));
            break;
          case 'P':
            _addSolid(PipeBlock(position: pos));
            break;
          case 'p':
            _addSolid(PipeBlock(position: pos, isTop: true));
            break;
          case 'o':
            add(Coin(position: pos + Vector2.all(GameConfig.tileSize / 2)));
            break;
          case 'G':
            add(Goomba(position: pos));
            break;
          case 'S':
            startPos = pos.clone();
            break;
          case 'F':
            add(GoalFlag(position: pos - Vector2(0, GameConfig.tileSize * 5)));
            break;
          default:
            break;
        }
      }
    }

    player = Player(position: startPos);
    add(player);

    status = GameStatus.playing;
    _setOverlays(playing: true);
  }

  bool _isEmpty(int row, int col) {
    if (row < 0 || row >= level.rowCount) return true;
    final String line = level.rows[row];
    if (col >= line.length) return true;
    return line[col] == ' ';
  }

  void _addSolid(GameBlock b) {
    solidBlocks.add(b);
    add(b);
  }

  // ---------------------------------------------------------------------------
  // Update loop: camera follow + timer + goal detection
  // ---------------------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);
    if (status != GameStatus.playing) return;

    elapsed += dt;

    // Countdown timer.
    _timeAccumulator += dt;
    if (_timeAccumulator >= 1.0) {
      _timeAccumulator -= 1.0;
      timeLeft.value = (timeLeft.value - 1).clamp(0, 9999);
      if (timeLeft.value == 0) {
        player.die();
      }
    }

    _updateCamera();
    _checkGoal();
  }

  void _updateCamera() {
    final double worldWidth = level.columns * GameConfig.tileSize;
    // Keep the player around 35% from the left edge.
    double target = player.position.x - size.x * 0.35;
    target = target.clamp(0, (worldWidth - size.x).clamp(0, double.infinity));
    cameraX += (target - cameraX) * 0.12; // smooth follow
    camera.viewfinder.position = Vector2(cameraX + size.x / 2, size.y / 2);
  }

  void _checkGoal() {
    final Iterable<GoalFlag> flags = children.query<GoalFlag>();
    for (final GoalFlag f in flags) {
      final double poleX = f.position.x + f.size.x / 2;
      if ((player.position.x + player.size.x / 2) >= poleX) {
        _completeLevel();
        return;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Events from components
  // ---------------------------------------------------------------------------

  void addScore(int amount) => score.value += amount;

  void addCoin() {
    coins.value += 1;
    score.value += 50;
    if (coins.value >= 100) {
      coins.value -= 100;
      lives.value += 1; // 1-up every 100 coins
    }
  }

  void spawnBonusCoin(Vector2 blockPos) {
    final Coin c = Coin(
      position: blockPos +
          Vector2(GameConfig.tileSize / 2, -GameConfig.tileSize * 0.2),
    );
    add(c);
    // Auto-collect the popped coin shortly after.
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (c.isMounted && c.collect()) addCoin();
    });
  }

  void onPlayerDied() {
    status = GameStatus.dead;
    audio.hurt();
    lives.value -= 1;
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (lives.value <= 0) {
        _gameOver();
      } else {
        _loadLevel(); // retry same level
      }
    });
  }

  void _completeLevel() {
    if (status != GameStatus.playing) return;
    status = GameStatus.levelComplete;
    audio.levelUp();
    // Time bonus.
    score.value += timeLeft.value * 10;
    _setOverlays();
    if (levelIndex.value + 1 >= Levels.count) {
      status = GameStatus.won;
      overlays.add(Overlays.gameWon);
    } else {
      overlays.add(Overlays.levelComplete);
    }
  }

  void nextLevel() {
    levelIndex.value += 1;
    _loadLevel();
  }

  void _gameOver() {
    status = GameStatus.gameOver;
    audio.gameOver();
    audio.stopMusic();
    _setOverlays();
    overlays.add(Overlays.gameOver);
  }

  void restartGame() {
    _setOverlays();
    startGame();
  }

  // ---------------------------------------------------------------------------
  // Pause
  // ---------------------------------------------------------------------------

  void pause() {
    if (status != GameStatus.playing) return;
    status = GameStatus.paused;
    pauseEngine();
    overlays.add(Overlays.pause);
  }

  void resume() {
    if (status != GameStatus.paused) return;
    status = GameStatus.playing;
    overlays.remove(Overlays.pause);
    resumeEngine();
  }

  void quitToMenu() {
    if (paused) resumeEngine();
    audio.stopMusic();
    status = GameStatus.menu;
    _setOverlays();
    overlays.add(Overlays.mainMenu);
  }

  // ---------------------------------------------------------------------------
  // Input helpers (called by on-screen controls)
  // ---------------------------------------------------------------------------

  void setMove(int direction) {
    if (status == GameStatus.playing) player.moveDirection = direction;
  }

  void doJump() {
    if (status == GameStatus.playing) player.jump();
  }

  // ---------------------------------------------------------------------------
  // Overlay management
  // ---------------------------------------------------------------------------

  void _setOverlays({bool playing = false}) {
    overlays.clear();
    if (playing) {
      overlays.add(Overlays.hud);
      overlays.add(Overlays.controls);
    }
  }
}
