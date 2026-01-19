import 'package:td/towers/tower.dart';
import 'package:td/towers/tower_controller.dart';

abstract class RangedTower extends Tower {
  RangedTower({
    required super.towerMaxLevel,
    required super.damage,
    required super.fireRate,
    required super.spotDistance,
    required super.attackSound,
    required super.position,
    required super.size,
    required RangedTowerController Function(RangedTower tower)
    controllerBuilder,
    super.level = 1,
  }) : super(
         controllerBuilder: (tower) => controllerBuilder(tower as RangedTower),
       );
}
