import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:td/enemies/enemy.dart';
import 'package:td/td.dart';
import 'package:td/towers/tower.dart';
import 'package:td/utils/debug_beam.dart';

abstract class RangedTower extends Tower with HasGameReference<TDGame> {
  RangedTower({
    required super.name,
    required super.images,
    required super.towerMaxLevel,
    required super.damage,
    required super.fireRate,
    required super.spotDistance,
    required super.attackSound,
    required super.position,
    required super.size,
    super.level = 1,
  });

  /// Seconds per animation frame while shooting.
  /// Override to speed up/slow down attack animation.
  double get shootFrameSeconds => 1 / 20;

  /// Radians-per-second turning speed.
  /// Set to `double.infinity` to snap instantly.
  double get turnSpeed => double.infinity;

  /// Sprite facing offset in radians.
  ///
  /// If your art points "up" by default, you may want `-pi / 2`.
  /// If it points "right" (east), leave `0.0`.
  double get aimAngleOffset => 0.0;

  double _cooldownSeconds = 0.0;

  AudioPool? _shootPool;
  String? _shootPoolAsset;
  Future<AudioPool>? _shootPoolFuture;

  List<Sprite>? _shootFrames;
  bool _isShootAnimating = false;
  int _shootFrameIndex = 0;
  double _shootFrameClock = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _rebuildShootFrames();
    await _ensureShootPool();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateShootAnimation(dt);

    final target = findTarget();
    if (target != null) {
      _rotateTowards(target.position, dt);
    }

    if (_cooldownSeconds > 0) {
      _cooldownSeconds -= dt;
      return;
    }

    if (target == null) return;

    // Ensure audio pool is ready (non-async update loop).
    if (_shootPool == null || _shootPoolAsset != attackSound) {
      unawaited(_ensureShootPool());
      return;
    }

    shoot(target);
    _cooldownSeconds = fireRate;
  }

  void _rotateTowards(Vector2 targetWorldPosition, double dt) {
    final origin = position;
    final dx = targetWorldPosition.x - origin.x;
    final dy = targetWorldPosition.y - origin.y;

    // Avoid atan2 noise if target is exactly at origin.
    if (dx == 0 && dy == 0) return;

    final desired = atan2(dy, dx) + aimAngleOffset;

    if (turnSpeed.isInfinite || dt <= 0) {
      angle = desired;
      return;
    }

    final delta = _shortestAngleDelta(angle, desired);
    final maxStep = turnSpeed * dt;
    if (delta.abs() <= maxStep) {
      angle = desired;
    } else {
      angle += delta.sign * maxStep;
    }
  }

  double _shortestAngleDelta(double from, double to) {
    var delta = to - from;

    // Wrap into [-pi, pi]
    delta = (delta + pi) % (2 * pi) - pi;
    if (delta < -pi) delta += 2 * pi;
    return delta;
  }

  @override
  Future<void> levelUp() async {
    await super.levelUp();
    _rebuildShootFrames();
    await _ensureShootPool();
  }

  /// Override for custom targeting logic.
  Enemy? findTarget() => _findNearestInSpotDistance();

  /// Override for custom attack behavior (projectiles, AOE, etc).
  void shoot(Enemy target) {
    _startShootAnimation();
    _shootPool?.start();

    game.world.add(
      DebugBeam(
        from: position.clone(),
        to: target.position.clone(),
        color: const Color(0xFFFF0000),
        strokeWidth: 3,
        ttlSeconds: 0.5,
      ),
    );

    target.takeHit(damage);
  }

  void _rebuildShootFrames() {
    final frames = <Sprite>[];
    for (var row = 0; row < sheet.rows; row++) {
      for (var col = 0; col < sheet.columns; col++) {
        frames.add(sheet.getSprite(row, col));
      }
    }
    if (frames.isEmpty) {
      frames.add(sheet.getSprite(0, 0));
    }

    _shootFrames = frames;
    _isShootAnimating = false;
    _shootFrameIndex = 0;
    _shootFrameClock = 0.0;

    // Ensure idle frame is frame 0.
    sprite = frames.first;
  }

  void _startShootAnimation() {
    final frames = _shootFrames;
    if (frames == null || frames.length <= 1) {
      return;
    }

    _isShootAnimating = true;
    _shootFrameIndex = 0;
    _shootFrameClock = 0.0;
    sprite = frames.first;
  }

  void _updateShootAnimation(double dt) {
    if (!_isShootAnimating) return;

    final frames = _shootFrames;
    if (frames == null || frames.length <= 1) {
      _isShootAnimating = false;
      return;
    }

    _shootFrameClock += dt;
    while (_shootFrameClock >= shootFrameSeconds) {
      _shootFrameClock -= shootFrameSeconds;
      _shootFrameIndex += 1;

      if (_shootFrameIndex >= frames.length) {
        // Finished: return to idle frame 0.
        _isShootAnimating = false;
        _shootFrameIndex = 0;
        sprite = frames.first;
        return;
      }

      sprite = frames[_shootFrameIndex];
    }
  }

  Future<AudioPool> _loadAudioPoolCached(
    String assetPath, {
    int maxPlayers = 8,
  }) {
    return loadCached<AudioPool>(
      cacheKey: 'audioPool:$assetPath:maxPlayers=$maxPlayers',
      loader: () => FlameAudio.createPool(assetPath, maxPlayers: maxPlayers),
    );
  }

  Future<void> _ensureShootPool() async {
    final asset = attackSound;
    if (_shootPoolAsset == asset && _shootPool != null) {
      return;
    }

    // Avoid stampeding futures if something calls this repeatedly.
    if (_shootPoolFuture != null && _shootPoolAsset == asset) {
      return;
    }

    _shootPoolAsset = asset;
    _shootPoolFuture = _loadAudioPoolCached(asset, maxPlayers: 8);
    _shootPool = await _shootPoolFuture!;
  }

  Enemy? _findNearestInSpotDistance() {
    Enemy? best;
    var bestDistance2 = double.infinity;

    final origin = position;
    final radius = spotDistance;
    final radius2 = radius * radius;

    for (final enemy in game.enemyIndex.queryRadius(origin, radius)) {
      final d2 = enemy.position.distanceToSquared(origin);
      if (d2 <= radius2 && d2 < bestDistance2) {
        best = enemy;
        bestDistance2 = d2;
      }
    }

    return best;
  }
}
