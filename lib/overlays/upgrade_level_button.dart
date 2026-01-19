import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'package:td/towers/tower.dart';

enum _UpgradeButtonState { idle, pressing, shining }

class UpgradeLevelButton extends SpriteAnimationComponent
    with TapCallbacks, HasGameReference {
  final Tower tower;

  _UpgradeButtonState _state = _UpgradeButtonState.idle;
  bool _ready = false;

  late final Map<int, SpriteAnimation> _idleByLevel;
  late final Map<int, SpriteAnimation> _shineByLevel;
  SpriteAnimation? _pressTo2;
  SpriteAnimation? _pressTo3;

  int? _pendingUpgradeTo;
  bool _upgradeInFlight = false;

  UpgradeLevelButton({required this.tower});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2.all(64);
    anchor = Anchor.center;

    _idleByLevel = {
      1: SpriteAnimation.spriteList([
        await Sprite.load('hud/level/arrow_1.png'),
      ], stepTime: 1),
      2: SpriteAnimation.spriteList([
        await Sprite.load('hud/level/arrow_2.png'),
      ], stepTime: 1),
      3: SpriteAnimation.spriteList([
        await Sprite.load('hud/level/arrow_3.png'),
      ], stepTime: 1),
    };

    _shineByLevel = {
      1: await _loadSheetAnimation(
        'hud/level/level_1_shine_sheet.png',
        stepTime: 0.06,
        loop: false,
      ),
      2: await _loadSheetAnimation(
        'hud/level/level_2_shine_sheet.png',
        stepTime: 0.06,
        loop: false,
      ),
      3: await _loadSheetAnimation(
        'hud/level/level_3_shine_sheet.png',
        stepTime: 0.06,
        loop: false,
      ),
    };

    _pressTo2 = await _loadSheetAnimation(
      'hud/level/Level_to_2_sheet.png',
      stepTime: 0.05,
      loop: false,
    );

    _pressTo3 = await _loadSheetAnimation(
      'hud/level/Level_to_3_sheet.png',
      stepTime: 0.05,
      loop: false,
    );

    _ready = true;
    _setIdleForCurrentLevel();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_ready) return;

    // If the tower leveled up from somewhere else, keep the button visuals in sync.
    if (_state == _UpgradeButtonState.idle) {
      final idle = _idleByLevel[tower.level];
      if (idle != null && animation != idle) {
        animation = idle;
      }
    }

    // Return to idle after a one-shot animation ends.
    final ticker = animationTicker;
    if (ticker == null) return;

    // When the press animation completes, perform the upgrade and then show shine.
    if (_state == _UpgradeButtonState.pressing &&
        ticker.done() &&
        _pendingUpgradeTo != null &&
        !_upgradeInFlight) {
      final targetLevel = _pendingUpgradeTo!;
      _pendingUpgradeTo = null;
      _upgradeInFlight = true;

      () async {
        await _upgradeTowerTo(targetLevel);

        final shine = _shineByLevel[targetLevel];
        if (shine != null) {
          _state = _UpgradeButtonState.shining;
          animation = shine;
          animationTicker?.reset();
        } else {
          _setIdleForCurrentLevel();
        }

        _upgradeInFlight = false;
      }();

      return;
    }

    if ((_state == _UpgradeButtonState.pressing ||
            _state == _UpgradeButtonState.shining) &&
        ticker.done()) {
      _setIdleForCurrentLevel();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (!_ready) return;
    if (_state != _UpgradeButtonState.idle) return;

    final nextLevel = tower.level + 1;
    if (nextLevel > tower.towerMaxLevel) {
      return;
    }

    _state = _UpgradeButtonState.pressing;

    final pressAnim = switch (nextLevel) {
      2 => _pressTo2,
      3 => _pressTo3,
      _ => null,
    };

    if (pressAnim == null) {
      _setIdleForCurrentLevel();
      return;
    }

    animation = pressAnim;
    animationTicker?.reset();

    // Defer the actual upgrade until the press animation finishes.
    _pendingUpgradeTo = nextLevel;
  }

  void _setIdleForCurrentLevel() {
    _state = _UpgradeButtonState.idle;
    animation = _idleByLevel[tower.level] ?? _idleByLevel[1];
    animationTicker?.reset();
  }

  Future<void> _upgradeTowerTo(int nextLevel) async {
    final evolvedSprite = await tower.loadSpriteForLevel(nextLevel);
    tower.levelUp(evolvedSprite);
  }

  Future<SpriteAnimation> _loadSheetAnimation(
    String path, {
    required double stepTime,
    required bool loop,
    double? frameSize,
  }) async {
    final image = await game.images.load(path);

    // Your sheets are exported as a horizontal strip (row 0) where each frame
    // is a square. If you change export size (e.g. 32x32 -> 128x128), this
    // automatically adapts.
    final effectiveFrameSize = frameSize ?? image.height.toDouble();
    final cols = (image.width / effectiveFrameSize).floor();
    final frameCount = max(1, cols);

    // Support 1-row or N-row sheets; we just animate row 0.
    final sheet = SpriteSheet(
      image: image,
      srcSize: Vector2(effectiveFrameSize, effectiveFrameSize),
    );

    return sheet.createAnimation(
      row: 0,
      from: 0,
      to: frameCount,
      stepTime: stepTime,
      loop: loop,
    );
  }
}
