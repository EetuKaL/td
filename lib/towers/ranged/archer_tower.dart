/* import 'package:flame/components.dart';
import 'package:td/towers/ranged_tower.dart';

class ArcherTower extends RangedTower {
  final hitRadius = 5.0;
  ArcherTower({required super.position, required super.size})
    : super(
        towerMaxLevel: 3,
        damage: const [15.0, 25.0, 40.0],
        fireRate: const [1.5, 1.2, 1.0],
        spotDistance: const [120.0, 140.0, 170.0],
        attackSound: const ['towers/archer/archer_shoot_1.wav'],
        controllerBuilder: RangedTowerController.fromTower,
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('towers/archer/archer_tower.png');
  }
}
 */
