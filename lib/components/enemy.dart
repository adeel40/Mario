import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../game/constants.dart';
import '../game/super_dash_game.dart';
import 'blocks.dart';

/// A Goomba-style walking enemy. Patrols horizontally, turns around when it
/// hits a wall, and is defeated when the player stomps it from above.
class Goomba extends PositionComponent
    with HasGameReference<SuperDashGame>, CollisionCallbacks {
  Goomba({required Vector2 position})
      : super(
          position: position,
          size: Vector2(GameConfig.tileSize * 0.9, GameConfig.tileSize * 0.9),
        );

  final Vector2 _velocity = Vector2(-GameConfig.enemySpeed, 0);
  bool dead = false;
  double _walkT = 0;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dead) return;

    _walkT += dt * 8;

    // Gravity.
    _velocity.y = math.min(
      _velocity.y + GameConfig.gravity * dt,
      GameConfig.maxFallSpeed,
    );

    // Horizontal move + wall check.
    position.x += _velocity.x * dt;
    if (_hitsSolidHorizontally()) {
      position.x -= _velocity.x * dt;
      _velocity.x = -_velocity.x; // turn around
    }

    // Vertical move + ground check.
    position.y += _velocity.y * dt;
    if (_landsOnSolid()) {
      _velocity.y = 0;
    }

    // Fell off the world.
    if (position.y > (game.level.rowCount + 4) * GameConfig.tileSize) {
      removeFromParent();
    }
  }

  bool _hitsSolidHorizontally() {
    for (final GameBlock b in game.solidBlocks) {
      if (toRect().overlaps(b.toRect())) return true;
    }
    return false;
  }

  bool _landsOnSolid() {
    final Rect feet = Rect.fromLTWH(position.x + 2, position.y + size.y - 2, size.x - 4, 4);
    for (final GameBlock b in game.solidBlocks) {
      if (feet.overlaps(b.toRect())) {
        position.y = b.position.y - size.y;
        return true;
      }
    }
    return false;
  }

  /// Squash and remove the enemy after being stomped.
  void stomp() {
    if (dead) return;
    dead = true;
    _velocity.setZero();
    add(
      ScaleEffect.to(
        Vector2(1.0, 0.25),
        EffectController(duration: 0.12),
      ),
    );
    add(
      RemoveEffect(delay: 0.35),
    );
  }

  @override
  void render(Canvas canvas) {
    final double w = size.x;
    final double h = size.y;

    // Body.
    final Rect body = Rect.fromLTWH(w * 0.1, h * 0.15, w * 0.8, h * 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, const Radius.circular(7)),
      Paint()..color = Palette.goombaBody,
    );
    // Face patch.
    canvas.drawOval(
      Rect.fromLTWH(w * 0.2, h * 0.35, w * 0.6, h * 0.32),
      Paint()..color = Palette.goombaFace,
    );

    if (!dead) {
      // Eyes.
      final Paint eyeWhite = Paint()..color = Colors.white;
      final Paint pupil = Paint()..color = Colors.black;
      canvas.drawOval(Rect.fromLTWH(w * 0.28, h * 0.24, w * 0.16, h * 0.2), eyeWhite);
      canvas.drawOval(Rect.fromLTWH(w * 0.56, h * 0.24, w * 0.16, h * 0.2), eyeWhite);
      canvas.drawOval(Rect.fromLTWH(w * 0.34, h * 0.30, w * 0.06, h * 0.09), pupil);
      canvas.drawOval(Rect.fromLTWH(w * 0.62, h * 0.30, w * 0.06, h * 0.09), pupil);
      // Angry brows.
      final Paint brow = Paint()
        ..color = Colors.black
        ..strokeWidth = 2;
      canvas.drawLine(Offset(w * 0.26, h * 0.22), Offset(w * 0.44, h * 0.28), brow);
      canvas.drawLine(Offset(w * 0.74, h * 0.22), Offset(w * 0.56, h * 0.28), brow);
    }

    // Feet (alternate up/down to simulate walking).
    final double lift = math.sin(_walkT) * h * 0.06;
    final Paint foot = Paint()..color = Palette.goombaFoot;
    canvas.drawOval(
        Rect.fromLTWH(w * 0.12, h * 0.7 - lift, w * 0.32, h * 0.22), foot);
    canvas.drawOval(
        Rect.fromLTWH(w * 0.56, h * 0.7 + lift, w * 0.32, h * 0.22), foot);
  }
}
