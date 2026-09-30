import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/constants.dart';

/// Base class for every solid, grid-aligned tile. Solid blocks stop the player
/// and enemies. Rendering is done with [CustomPainter]-style canvas calls so we
/// need zero external image assets.
abstract class GameBlock extends PositionComponent {
  GameBlock({required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(GameConfig.tileSize),
        );

  bool get solid => true;
}

/// Solid dirt/ground tile with a grassy top edge.
class GroundBlock extends GameBlock {
  GroundBlock({required super.position, this.hasGrassTop = false});

  final bool hasGrassTop;

  @override
  void render(Canvas canvas) {
    final Rect r = size.toRect();
    canvas.drawRect(r, Paint()..color = Palette.ground);

    // Speckle texture.
    final Paint dark = Paint()..color = Palette.groundDark;
    canvas.drawRect(Rect.fromLTWH(0, r.height * 0.55, r.width, 2), dark);
    canvas.drawRect(Rect.fromLTWH(r.width * 0.2, r.height * 0.75, 4, 4), dark);
    canvas.drawRect(Rect.fromLTWH(r.width * 0.6, r.height * 0.35, 4, 4), dark);

    if (hasGrassTop) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, r.width, r.height * 0.28),
        Paint()..color = Palette.groundTop,
      );
    }
    _outline(canvas, r);
  }
}

/// Breakable brick block.
class BrickBlock extends GameBlock {
  BrickBlock({required super.position});

  @override
  void render(Canvas canvas) {
    final Rect r = size.toRect();
    canvas.drawRect(r, Paint()..color = Palette.brick);

    final Paint mortar = Paint()
      ..color = Palette.brickDark
      ..strokeWidth = 2;
    // Two rows of offset bricks.
    canvas.drawLine(Offset(0, r.height / 2), Offset(r.width, r.height / 2), mortar);
    canvas.drawLine(Offset(r.width / 2, 0), Offset(r.width / 2, r.height / 2), mortar);
    canvas.drawLine(Offset(r.width / 4, r.height / 2), Offset(r.width / 4, r.height), mortar);
    canvas.drawLine(
        Offset(r.width * 3 / 4, r.height / 2), Offset(r.width * 3 / 4, r.height), mortar);
    _outline(canvas, r);
  }
}

/// A question block. Holds a coin until bumped, then becomes an inert used block.
class QuestionBlock extends GameBlock {
  QuestionBlock({required super.position});

  bool used = false;
  double _t = 0;

  @override
  void update(double dt) {
    _t += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final Rect r = size.toRect();
    if (used) {
      canvas.drawRect(r, Paint()..color = Palette.usedBlock);
      _outline(canvas, r);
      return;
    }
    // Pulsing glow.
    final double glow = 0.5 + 0.5 * math.sin(_t * 4);
    canvas.drawRect(r, Paint()..color = Palette.question);
    canvas.drawRect(
      r.deflate(3),
      Paint()..color = Color.lerp(Palette.questionDark, Palette.question, glow)!,
    );
    // '?' mark.
    final TextPainter tp = TextPainter(
      text: const TextSpan(
        text: '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((r.width - tp.width) / 2, (r.height - tp.height) / 2));
    _outline(canvas, r);
  }
}

/// Pipe segment (both top and body are solid; visuals differ slightly).
class PipeBlock extends GameBlock {
  PipeBlock({required super.position, this.isTop = false});

  final bool isTop;

  @override
  void render(Canvas canvas) {
    final Rect r = size.toRect();
    canvas.drawRect(r, Paint()..color = Palette.pipeGreen);
    // Left highlight, right shadow for a rounded tube feel.
    canvas.drawRect(
        Rect.fromLTWH(0, 0, r.width * 0.18, r.height), Paint()..color = const Color(0xFF56C356));
    canvas.drawRect(Rect.fromLTWH(r.width * 0.82, 0, r.width * 0.18, r.height),
        Paint()..color = Palette.pipeGreenDark);
    if (isTop) {
      canvas.drawRect(Rect.fromLTWH(-2, 0, r.width + 4, r.height * 0.35),
          Paint()..color = Palette.pipeGreen);
      _outline(canvas, Rect.fromLTWH(-2, 0, r.width + 4, r.height * 0.35));
    }
    _outline(canvas, r);
  }
}

void _outline(Canvas canvas, Rect r) {
  canvas.drawRect(
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black.withValues(alpha: 0.35),
  );
}
