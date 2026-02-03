import 'dart:math';
import 'package:flame/components.dart';
import 'package:td/enemies/enemy.dart';

class Zombie extends Enemy {
  static Map<String, SpriteAnimation> animationCache = {};
  static const frameSize = 128.0;
  late int variant;
  bool _dying = false;
  bool _hurting = false;

  Zombie({
    required super.position,
    required super.size,
    required super.path,
    super.hp = 100,
    super.speed = 10,
    super.range = 5,
  }) {
    variant = Random().nextInt(4) + 1;
    anchor = Anchor.bottomCenter;
  }

  late final SpriteAnimation walk;
  late final SpriteAnimation hurt;
  late final SpriteAnimation death;
  late final SpriteAnimation attack;
  late final SpriteAnimation idle;

  @override
  bool get canMove => !_dying && !_hurting;

  @override
  void onDamaged(double damage) {
    if (_dying || _hurting || !isLoaded) return;
    _hurting = true;
    animation = hurt;
    animationTicker?.reset();
    animationTicker?.onComplete = () {
      _hurting = false;
      if (!_dying) animation = walk;
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

    animation = death;
    animationTicker?.reset();
    animationTicker?.onComplete = removeNow;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    walk = animationCache['variant_${variant}_walk'] ??=
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

    animation = walk;

    hurt = animationCache['variant_${variant}_hurt'] ??=
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

    death = animationCache['variant_${variant}_death'] ??=
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

    attack = animationCache['variant_${variant}_attack'] ??=
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
    idle = animationCache['variant_${variant}_idle'] ??=
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
