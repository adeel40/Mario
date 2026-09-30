import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around flame_audio so gameplay code can trigger sounds without
/// worrying about caching, missing files, or platform quirks. All calls are
/// guarded: if an asset is missing the game still runs silently.
class AudioManager {
  bool enabled = true;
  bool _loaded = false;

  /// Filenames expected under assets/audio/. See assets/audio/README.md for how
  /// to drop in real sound files (short .wav/.mp3 clips).
  static const List<String> _sfx = <String>[
    'jump.wav',
    'coin.wav',
    'stomp.wav',
    'hurt.wav',
    'levelup.wav',
    'gameover.wav',
  ];

  static const String _bgm = 'music.mp3';

  Future<void> preload() async {
    try {
      await FlameAudio.audioCache.loadAll(_sfx);
      _loaded = true;
    } catch (e) {
      // Missing assets are non-fatal — the game just plays silently.
      _loaded = false;
      if (kDebugMode) {
        debugPrint('AudioManager: sfx not preloaded ($e). Game runs muted.');
      }
    }
  }

  void _play(String file, {double volume = 0.8}) {
    if (!enabled || !_loaded) return;
    try {
      FlameAudio.play(file, volume: volume);
    } catch (_) {/* ignore */}
  }

  void jump() => _play('jump.wav', volume: 0.6);
  void coin() => _play('coin.wav', volume: 0.7);
  void stomp() => _play('stomp.wav', volume: 0.7);
  void hurt() => _play('hurt.wav');
  void levelUp() => _play('levelup.wav');
  void gameOver() => _play('gameover.wav');

  Future<void> startMusic() async {
    if (!enabled) return;
    try {
      await FlameAudio.bgm.initialize();
      await FlameAudio.bgm.play(_bgm, volume: 0.35);
    } catch (_) {/* ignore missing music */}
  }

  Future<void> stopMusic() async {
    try {
      await FlameAudio.bgm.stop();
    } catch (_) {/* ignore */}
  }

  void toggle() {
    enabled = !enabled;
    if (!enabled) stopMusic();
  }
}
