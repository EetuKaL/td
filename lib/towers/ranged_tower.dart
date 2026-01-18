import 'package:td/towers/tower.dart';
import 'package:td/towers/tower_controller.dart';

abstract class RangedTower extends Tower {
  RangedTower({
    required super.position,
    required super.size,
    required RangedTowerController Function(RangedTower tower)
    controllerBuilder,
  }) : super(
         controllerBuilder: (tower) => controllerBuilder(tower as RangedTower),
       );
}
