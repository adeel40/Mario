import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/constants.dart';
import '../game/super_dash_game.dart';

/// A gradient sky + rolling hills + drifting clouds. Rendered relative to the
/// camera so it produces a gentle parallax effect without any image assets.
class ParallaxBackground extends PositionComponent
    with HasGameReference<SuperDashGame> {
  ParallaxBackground({required this.worldWidth, required this.worldHeight});

  final double worldWidth;
  final double worldHeight;

  @override
  int get priority => -100;

  @override
  void render(Canvas canvas) {
    final Size screen = game.size.toSize();
    final double camX = game.cameraX;

    // Sky gradient fills the whole visible screen.
    final Rect sky = Rect.fromLTWH(camX, 0, screen.width, screen.height);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Palette.skyTop, Palette.skyBottom],
        ).createShader(sky),
    );

    _drawHills(canvas, camX, screen);
    _drawClouds(canvas, camX, screen);
  }

  void _drawHills(Canvas canvas, double camX, Size screen) {
    final double baseY = worldHeight - GameConfig.tileSize * 2;
    // Far hills move slower than the camera (parallax factor 0.4).
    final double offset = camX * 0.6;
    final Paint far = Paint()..color = Palette.hillGreenDark;
    final Paint near = Paint()..color = Palette.hillGreen;

    for (int i = -1; i < (screen.width / 180).ceil() + 2; i++) {
      final double hx = camX + i * 180 + (camX * 0.4 - offset) % 180;
      _hill(canvas, hx, baseY, 120, far);
    }
    for (int i = -1; i < (screen.width / 140).ceil() + 2; i++) {
      final double hx = camX + i * 140 + (camX * 0.25) % 140;
      _hill(canvas, hx, baseY + 20, 80, near);
    }
  }

  void _hill(Canvas canvas, double cx, double baseY, double r, Paint paint) {
    final Path p = Path()
      ..moveTo(cx - r, baseY)
      ..arcToPoint(Offset(cx + r, baseY), radius: Radius.circular(r), clockwise: true)
      ..close();
    canvas.drawPath(p, paint);
  }

  void _drawClouds(Canvas canvas, double camX, Size screen) {
    final Paint cloud = Paint()..color = Palette.cloud.withValues(alpha: 0.9);
    for (int i = 0; i < 6; i++) {
      // Clouds drift very slowly (parallax factor 0.2) and loop.
      const double period = 520.0;
      final double cx = camX * 0.2 +
          (i * 260 + (game.elapsed * 8)) % (screen.width + period) -
          period / 2 +
          camX;
      final double cy = 40 + (i % 3) * 46;
      _cloud(canvas, cx, cy, cloud);
    }
  }

  void _cloud(Canvas canvas, double x, double y, Paint paint) {
    canvas.drawOval(Rect.fromLTWH(x, y, 60, 30), paint);
    canvas.drawOval(Rect.fromLTWH(x + 24, y - 14, 50, 40), paint);
    canvas.drawOval(Rect.fromLTWH(x + 52, y, 56, 30), paint);
  }
}

/// The level goal: a tall pole with a waving flag. Reaching it completes the
/// level.
class GoalFlag extends PositionComponent with HasGameReference<SuperDashGame> {
  GoalFlag({required Vector2 position})
      : super(
          position: position,
          size: Vector2(GameConfig.tileSize, GameConfig.tileSize * 6),
        );

  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // Pole.
    canvas.drawRect(
      Rect.fromLTWH(size.x / 2 - 3, 0, 6, size.y),
      Paint()..color = Palette.flagPole,
    );
    // Knob.
    canvas.drawCircle(Offset(size.x / 2, 0), 7, Paint()..color = const Color(0xFF66BB6A));
    // Waving flag.
    final double wave = math.sin(_t * 3) * 4;
    final Path flag = Path()
      ..moveTo(size.x / 2, 8)
      ..lineTo(size.x / 2 + 34 + wave, 20)
      ..lineTo(size.x / 2, 34)
      ..close();
    canvas.drawPath(flag, Paint()..color = Palette.flagCloth);
  }
}
