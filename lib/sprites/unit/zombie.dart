import 'dart:math';
import 'package:flame/components.dart';
import 'package:td/sprites/unit/units/enemy.dart';

class Zombie extends Enemy {
  static Map<String, SpriteAnimation> animationCache = {};
  static const frameSize = 128.0;
  late int variant;
  bool _dying = false;
  bool _hurting = false;

  Zombie({
    required Vector2 position,
    required Vector2 size,
    required List<Vector2> path,
    double hp = 100,
    double speed = 10,
    double range = 5,
  }) : super(
         position: position,
         size: size,
         path: path,
         hp: hp,
         speed: speed,
         range: range,
       ) {
    variant = Random().nextInt(4) + 1;
    anchor = Anchor.bottomCenter;
  }

  late final SpriteAnimation aWalk;
  late final SpriteAnimation aHurt;
  late final SpriteAnimation aDeath;
  late final SpriteAnimation aAttack;
  late final SpriteAnimation aIdle;

  @override
  bool get canMove => !_dying && !_hurting;

  @override
  void onDamaged(double damage) {
    if (_dying || _hurting || !isLoaded) return;
    _hurting = true;
    animation = aHurt;
    animationTicker?.reset();
    animationTicker?.onComplete = () {
      _hurting = false;
      if (!_dying) animation = aWalk;
    };
  }

  @override
  void onKilled() {
    if (_dying) return;
    _dying = true;
    _hurting = false;

    if (!isLoaded) {
      removeNow();
      return;
    }

    animation = aDeath;
    animationTicker?.reset();
    animationTicker?.onComplete = removeNow;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    aWalk = animationCache['variant_${variant}_walk'] ??=
        await Sprite.load('enemies/zombie/variant_$variant/Walk.png').then((
          sprite,
        ) {
          return SpriteAnimation.fromFrameData(
            sprite.image,
            SpriteAnimationData.sequenced(
              amount: sprite.image.width ~/ frameSize,
              stepTime: 0.1,
              textureSize: Vector2.all(frameSize),
            ),
          );
        });

    animation = aWalk;

    aHurt = animationCache['variant_${variant}_hurt'] ??=
        await Sprite.load('enemies/zombie/variant_$variant/Hurt.png').then(
          (sprite) => SpriteAnimation.fromFrameData(
            sprite.image,
            SpriteAnimationData.sequenced(
              amount: sprite.image.width ~/ frameSize,
              stepTime: 0.1,
              textureSize: Vector2.all(frameSize),
              loop: false,
            ),
          ),
        );

    aDeath = animationCache['variant_${variant}_death'] ??=
        await Sprite.load('enemies/zombie/variant_$variant/Dead.png').then(
          (sprite) => SpriteAnimation.fromFrameData(
            sprite.image,
            SpriteAnimationData.sequenced(
              amount: sprite.image.width ~/ frameSize,
              stepTime: 0.1,
              textureSize: Vector2.all(frameSize),
              loop: false,
            ),
          ),
        );

    aAttack = animationCache['variant_${variant}_attack'] ??=
        await Sprite.load('enemies/zombie/variant_$variant/Attack.png').then(
          (sprite) => SpriteAnimation.fromFrameData(
            sprite.image,
            SpriteAnimationData.sequenced(
              amount: sprite.image.width ~/ frameSize,
              stepTime: 0.1,
              textureSize: Vector2.all(frameSize),
              loop: false,
            ),
          ),
        );
    aIdle = animationCache['variant_${variant}_idle'] ??=
        await Sprite.load('enemies/zombie/variant_$variant/Idle.png').then(
          (sprite) => SpriteAnimation.fromFrameData(
            sprite.image,
            SpriteAnimationData.sequenced(
              amount: sprite.image.width ~/ frameSize,
              stepTime: 0.1,
              textureSize: Vector2.all(frameSize),
            ),
          ),
        );
  }
}
