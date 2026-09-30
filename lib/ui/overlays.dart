import 'package:flutter/material.dart';

import '../game/levels.dart';
import '../game/super_dash_game.dart';

/// Central registry of overlay ids so the game and app agree on names.
class Overlays {
  Overlays._();
  static const String mainMenu = 'mainMenu';
  static const String hud = 'hud';
  static const String controls = 'controls';
  static const String pause = 'pause';
  static const String gameOver = 'gameOver';
  static const String levelComplete = 'levelComplete';
  static const String gameWon = 'gameWon';
}

// ---------------------------------------------------------------------------
// Shared building blocks
// ---------------------------------------------------------------------------

class _GameButton extends StatelessWidget {
  const _GameButton({
    required this.label,
    required this.onTap,
    this.color = const Color(0xFFE52521),
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(0, 4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _panel({required List<Widget> children}) {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xF20D1B3E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Main menu
// ---------------------------------------------------------------------------

class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({super.key, required this.game});
  final SuperDashGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF5C94FC), Color(0xFF9AD0F5)],
        ),
      ),
      child: _panel(
        children: <Widget>[
          const Text(
            'SUPER DASH',
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 3,
              shadows: <Shadow>[
                Shadow(color: Color(0xFFE52521), offset: Offset(3, 3)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'A retro platform adventure',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 26),
          _GameButton(
            label: 'START GAME',
            icon: Icons.play_arrow_rounded,
            onTap: () {
              game.overlays.remove(Overlays.mainMenu);
              game.startGame();
            },
          ),
          const SizedBox(height: 14),
          ValueListenableBuilder<int>(
            valueListenable: game.levelIndex,
            builder: (_, __, ___) => Text(
              '${Levels.count} levels • stomp enemies • grab coins',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HUD (score / coins / lives / time)
// ---------------------------------------------------------------------------

class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});
  final SuperDashGame game;

  Widget _stat(String label, ValueNotifier<int> vn, {String prefix = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
        ValueListenableBuilder<int>(
          valueListenable: vn,
          builder: (_, int v, __) => Text(
            '$prefix${v.toString().padLeft(2, '0')}',
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _stat('SCORE', game.score),
            _stat('COINS', game.coins, prefix: '\u2022 '),
            _stat('LIVES', game.lives, prefix: '\u2665 '),
            _stat('TIME', game.timeLeft),
            IconButton(
              onPressed: game.pause,
              icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 34),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// On-screen touch controls
// ---------------------------------------------------------------------------

class ControlsOverlay extends StatelessWidget {
  const ControlsOverlay({super.key, required this.game});
  final SuperDashGame game;

  Widget _dpad(IconData icon, int dir) {
    return Listener(
      onPointerDown: (_) => game.setMove(dir),
      onPointerUp: (_) => game.setMove(0),
      onPointerCancel: (_) => game.setMove(0),
      child: Container(
        width: 66,
        height: 66,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: 38),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _dpad(Icons.arrow_left_rounded, -1),
            _dpad(Icons.arrow_right_rounded, 1),
            const Spacer(),
            // Jump button.
            Listener(
              onPointerDown: (_) => game.doJump(),
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: const Color(0xCCE52521),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Center(
                  child: Text('JUMP',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pause / Game over / Level complete / Win
// ---------------------------------------------------------------------------

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});
  final SuperDashGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: _panel(children: <Widget>[
        const Text('PAUSED',
            style: TextStyle(
                fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 20),
        _GameButton(label: 'RESUME', icon: Icons.play_arrow, onTap: game.resume),
        const SizedBox(height: 12),
        _GameButton(
            label: 'MAIN MENU',
            color: const Color(0xFF455A64),
            icon: Icons.home,
            onTap: game.quitToMenu),
      ]),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});
  final SuperDashGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: _panel(children: <Widget>[
        const Text('GAME OVER',
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.w900, color: Color(0xFFE52521))),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: game.score,
          builder: (_, int s, __) => Text('Final Score: $s',
              style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
        const SizedBox(height: 22),
        _GameButton(label: 'PLAY AGAIN', icon: Icons.replay, onTap: () {
          game.overlays.remove(Overlays.gameOver);
          game.restartGame();
        }),
        const SizedBox(height: 12),
        _GameButton(
            label: 'MAIN MENU',
            color: const Color(0xFF455A64),
            icon: Icons.home,
            onTap: game.quitToMenu),
      ]),
    );
  }
}

class LevelCompleteOverlay extends StatelessWidget {
  const LevelCompleteOverlay({super.key, required this.game});
  final SuperDashGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: _panel(children: <Widget>[
        const Text('LEVEL CLEAR!',
            style: TextStyle(
                fontSize: 34, fontWeight: FontWeight.w900, color: Color(0xFF66BB6A))),
        const SizedBox(height: 10),
        ValueListenableBuilder<int>(
          valueListenable: game.score,
          builder: (_, int s, __) => Text('Score: $s',
              style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
        const SizedBox(height: 22),
        _GameButton(label: 'NEXT LEVEL', icon: Icons.skip_next, onTap: () {
          game.overlays.remove(Overlays.levelComplete);
          game.nextLevel();
        }),
      ]),
    );
  }
}

class GameWonOverlay extends StatelessWidget {
  const GameWonOverlay({super.key, required this.game});
  final SuperDashGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF1A237E), Color(0xFF4A148C)],
        ),
      ),
      child: _panel(children: <Widget>[
        const Text('🏆  YOU WIN!  🏆',
            style: TextStyle(
                fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFFFFD54F))),
        const SizedBox(height: 8),
        const Text('You cleared every level!',
            style: TextStyle(color: Colors.white70, fontSize: 15)),
        const SizedBox(height: 12),
        ValueListenableBuilder<int>(
          valueListenable: game.score,
          builder: (_, int s, __) => Text('Final Score: $s',
              style: const TextStyle(color: Colors.white, fontSize: 20)),
        ),
        const SizedBox(height: 22),
        _GameButton(label: 'PLAY AGAIN', icon: Icons.replay, onTap: () {
          game.overlays.remove(Overlays.gameWon);
          game.restartGame();
        }),
        const SizedBox(height: 12),
        _GameButton(
            label: 'MAIN MENU',
            color: const Color(0xFF455A64),
            icon: Icons.home,
            onTap: game.quitToMenu),
      ]),
    );
  }
}
