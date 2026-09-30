import 'package:flutter/material.dart';

/// Global tuning values for physics, sizing and palette.
class GameConfig {
  GameConfig._();

  /// Size (in world units) of a single tile. The whole game is grid based.
  static const double tileSize = 32.0;

  /// Downward acceleration applied every second (world units / s^2).
  static const double gravity = 1400.0;

  /// Horizontal run speed of the player (world units / s).
  static const double playerMoveSpeed = 190.0;

  /// Initial upward velocity when the player jumps.
  static const double playerJumpSpeed = 560.0;

  /// Terminal falling speed so the player never tunnels through tiles.
  static const double maxFallSpeed = 900.0;

  /// Walking speed of a Goomba-style enemy.
  static const double enemySpeed = 55.0;

  /// How many lives the player starts a fresh game with.
  static const int startingLives = 3;
}

/// Named colours for the hand-painted sprites and backgrounds.
class Palette {
  Palette._();

  static const Color skyTop = Color(0xFF5C94FC);
  static const Color skyBottom = Color(0xFF9AD0F5);
  static const Color hillGreen = Color(0xFF3EA037);
  static const Color hillGreenDark = Color(0xFF2E7A29);
  static const Color cloud = Color(0xFFFFFFFF);

  static const Color brick = Color(0xFFC84C0C);
  static const Color brickDark = Color(0xFF9E3B08);
  static const Color brickMortar = Color(0xFF000000);

  static const Color ground = Color(0xFFC07A32);
  static const Color groundTop = Color(0xFF6BAF2A);
  static const Color groundDark = Color(0xFF8A5620);

  static const Color question = Color(0xFFFBC02D);
  static const Color questionDark = Color(0xFFCC9A00);
  static const Color usedBlock = Color(0xFF9E6B3B);

  static const Color coin = Color(0xFFFFD54F);
  static const Color coinShine = Color(0xFFFFF59D);

  static const Color pipeGreen = Color(0xFF2FA02F);
  static const Color pipeGreenDark = Color(0xFF1E6E1E);

  static const Color flagPole = Color(0xFFBDBDBD);
  static const Color flagCloth = Color(0xFF2E7D32);

  static const Color playerRed = Color(0xFFE52521);
  static const Color playerBlue = Color(0xFF2953C4);
  static const Color playerSkin = Color(0xFFFFC69A);
  static const Color playerBrown = Color(0xFF7A3F00);

  static const Color goombaBody = Color(0xFF8B4513);
  static const Color goombaFoot = Color(0xFF3E2210);
  static const Color goombaFace = Color(0xFFF5DEB3);
}
