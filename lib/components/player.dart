import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/constants.dart';
import '../game/super_dash_game.dart';
import 'blocks.dart';
import 'coin.dart';
import 'enemy.dart';

/// The player-controlled hero. Handles input-driven movement, gravity,
/// axis-separated collision resolution against solid blocks, coin pickup,
/// enemy stomping and death.
class Player extends PositionComponent
    with HasGameReference<SuperDashGame>, CollisionCallbacks {
  Player({required Vector2 position})
      : super(
          position: position,
          size: Vector2(GameConfig.tileSize * 0.8, GameConfig.tileSize * 0.95),
        );

  final Vector2 velocity = Vector2.zero();

  int moveDirection = 0; // -1 left, 0 idle, 1 right
  bool _jumpQueued = false;
  bool onGround = false;
  bool facingRight = true;
  bool dead = false;

  double _animT = 0;
  double _invincible = 0; // brief i-frames after taking damage

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.active));
  }

  void jump() => _jumpQueued = true;

  @override
  void update(double dt) {
    super.update(dt);
    if (dead) {
      // Death animation: pop up then fall through the world.
      velocity.y += GameConfig.gravity * dt;
      position.y += velocity.y * dt;
      return;
    }

    _animT += dt;
    if (_invincible > 0) _invincible -= dt;

    // --- Horizontal ---
    velocity.x = moveDirection * GameConfig.playerMoveSpeed;
    if (moveDirection != 0) facingRight = moveDirection > 0;

    position.x += velocity.x * dt;
    _resolveHorizontal();

    // --- Vertical ---
    if (_jumpQueued && onGround) {
      velocity.y = -GameConfig.playerJumpSpeed;
      onGround = false;
      game.audio.jump();
    }
    _jumpQueued = false;

    velocity.y = math.min(
      velocity.y + GameConfig.gravity * dt,
      GameConfig.maxFallSpeed,
    );
    position.y += velocity.y * dt;
    _resolveVertical();

    _checkPickupsAndEnemies();
    _checkBounds();
  }

  void _resolveHorizontal() {
    for (final GameBlock b in game.solidBlocks) {
      if (!toRect().overlaps(b.toRect())) continue;
      if (velocity.x > 0) {
        position.x = b.position.x - size.x;
      } else if (velocity.x < 0) {
        position.x = b.position.x + b.size.x;
      }
      velocity.x = 0;
    }
    // Keep the player inside the left world edge.
    if (position.x < 0) position.x = 0;
  }

  void _resolveVertical() {
    onGround = false;
    for (final GameBlock b in game.solidBlocks) {
      if (!toRect().overlaps(b.toRect())) continue;
      if (velocity.y > 0) {
        // Falling: land on top.
        position.y = b.position.y - size.y;
        velocity.y = 0;
        onGround = true;
      } else if (velocity.y < 0) {
        // Rising: bonk head.
        position.y = b.position.y + b.size.y;
        velocity.y = 0;
        _onHeadBump(b);
      }
    }
  }

  void _onHeadBump(GameBlock b) {
    if (b is QuestionBlock && !b.used) {
      b.used = true;
      game.audio.coin();
      game.addScore(200);
      game.spawnBonusCoin(b.position);
    }
  }

  void _checkPickupsAndEnemies() {
    final Rect me = toRect();

    // Coins.
    for (final Coin c in game.children.query<Coin>()) {
      if (me.overlaps(c.toRect()) && c.collect()) {
        game.audio.coin();
        game.addCoin();
      }
    }

    // Enemies.
    for (final Goomba g in game.children.query<Goomba>()) {
      if (g.dead) continue;
      if (!me.overlaps(g.toRect())) continue;

      final bool falling = velocity.y > 0;
      final bool above = (position.y + size.y) - g.position.y < g.size.y * 0.6;
      if (falling && above) {
        // Stomp!
        g.stomp();
        game.audio.stomp();
        game.addScore(100);
        velocity.y = -GameConfig.playerJumpSpeed * 0.6; // bounce
      } else if (_invincible <= 0) {
        _takeHit();
      }
    }
  }

  void _takeHit() {
    game.audio.hurt();
    die();
  }

  void _checkBounds() {
    // Fell into a pit.
    if (position.y > (game.level.rowCount + 3) * GameConfig.tileSize) {
      die();
    }
  }

  void die() {
    if (dead) return;
    dead = true;
    velocity
      ..x = 0
      ..y = -GameConfig.playerJumpSpeed * 0.7;
    game.onPlayerDied();
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (!facingRight) {
      // Mirror horizontally around the centre.
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }
    if (_invincible > 0 && (_invincible * 20).floor().isEven) {
      canvas.restore();
      return; // blink while invincible
    }
    _paintHero(canvas);
    canvas.restore();
  }

  void _paintHero(Canvas canvas) {
    final double w = size.x;
    final double h = size.y;
    final bool moving = moveDirection != 0 && onGround;
    final double legSwing = moving ? math.sin(_animT * 14) * (h * 0.08) : 0;

    // Legs (overalls).
    final Paint blue = Paint()..color = Palette.playerBlue;
    canvas.drawRect(Rect.fromLTWH(w * 0.18, h * 0.62, w * 0.28, h * 0.38 - legSwing), blue);
    canvas.drawRect(Rect.fromLTWH(w * 0.54, h * 0.62, w * 0.28, h * 0.38 + legSwing), blue);
    // Shoes.
    final Paint brown = Paint()..color = Palette.playerBrown;
    canvas.drawOval(
        Rect.fromLTWH(w * 0.12, h * 0.9 - legSwing, w * 0.36, h * 0.12), brown);
    canvas.drawOval(
        Rect.fromLTWH(w * 0.52, h * 0.9 + legSwing, w * 0.36, h * 0.12), brown);

    // Torso (red shirt) + overall straps.
    final Paint red = Paint()..color = Palette.playerRed;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.15, h * 0.4, w * 0.7, h * 0.28), const Radius.circular(4)),
      red,
    );
    canvas.drawRect(Rect.fromLTWH(w * 0.3, h * 0.42, w * 0.08, h * 0.24), blue);
    canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.42, w * 0.08, h * 0.24), blue);

    // Arms.
    canvas.drawOval(Rect.fromLTWH(w * 0.02, h * 0.42, w * 0.2, h * 0.2), red);
    canvas.drawOval(Rect.fromLTWH(w * 0.78, h * 0.42, w * 0.2, h * 0.2), red);
    // Hands (gloves).
    canvas.drawOval(
        Rect.fromLTWH(-w * 0.02, h * 0.55, w * 0.18, h * 0.16), Paint()..color = Colors.white);
    canvas.drawOval(
        Rect.fromLTWH(w * 0.84, h * 0.55, w * 0.18, h * 0.16), Paint()..color = Colors.white);

    // Head.
    final Paint skin = Paint()..color = Palette.playerSkin;
    canvas.drawOval(Rect.fromLTWH(w * 0.2, h * 0.14, w * 0.6, h * 0.34), skin);
    // Cap.
    canvas.drawArc(
      Rect.fromLTWH(w * 0.14, h * 0.02, w * 0.72, h * 0.36),
      math.pi,
      math.pi,
      true,
      red,
    );
    canvas.drawRect(Rect.fromLTWH(w * 0.5, h * 0.2, w * 0.42, h * 0.07), red); // brim
    // Eye.
    canvas.drawOval(
        Rect.fromLTWH(w * 0.55, h * 0.26, w * 0.08, h * 0.1), Paint()..color = Colors.black);
    // Moustache.
    canvas.drawRect(
        Rect.fromLTWH(w * 0.5, h * 0.4, w * 0.28, h * 0.05), Paint()..color = Palette.playerBrown);
  }
}
