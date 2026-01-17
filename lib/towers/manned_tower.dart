import 'package:td/towers/tower.dart';
import 'package:td/towers/tower_man/tower_man.dart';

abstract class MannedTower extends Tower {
  final List<TowerMan> crew;
  final int crewCount;
  MannedTower({
    required super.position,
    required super.size,
    required this.crew,
    required this.crewCount,
    required super.controllerBuilder,
  });

  // Inherit base attack behavior for now.
}
