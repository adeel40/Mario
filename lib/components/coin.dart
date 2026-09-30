import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../game/constants.dart';
import '../game/super_dash_game.dart';

/// A collectible coin. Spins for visual flair and disappears with a little
/// pop when picked up by the player.
class Coin extends PositionComponent with HasGameReference<SuperDashGame> {
  Coin({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(GameConfig.tileSize * 0.6),
          anchor: Anchor.center,
        );

  double _t = math.Random().nextDouble() * math.pi * 2;
  bool _collected = false;

  @override
  void update(double dt) {
    _t += dt * 4;
    super.update(dt);
  }

  /// Called by the player when overlapping. Returns true the first time only.
  bool collect() {
    if (_collected) return false;
    _collected = true;
    add(
      ScaleEffect.to(
        Vector2.all(1.7),
        EffectController(duration: 0.18),
        onComplete: removeFromParent,
      ),
    );
    return true;
  }

  @override
  void render(Canvas canvas) {
    // Horizontal "spin" by squashing width with a cosine.
    final double w = size.x * (0.25 + 0.75 * math.cos(_t).abs());
    final Rect r = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: w,
      height: size.y,
    );
    canvas.drawOval(r, Paint()..color = Palette.coin);
    canvas.drawOval(r.deflate(w * 0.18), Paint()..color = Palette.coinShine);
    canvas.drawOval(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Palette.questionDark,
    );
  }
}
