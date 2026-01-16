import 'package:td/towers/tower_man/tower_man.dart';

class SwordMan extends TowerMan {
  SwordMan({required super.position, required super.size})
    : super(walkSpeed: 50.0, damage: 10.0, range: 30.0, health: 100.0);
}
