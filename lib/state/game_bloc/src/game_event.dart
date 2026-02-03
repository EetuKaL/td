import 'package:td/towers/tower.dart';

sealed class GameEvent {
  const GameEvent();
}

class TowerSelect extends GameEvent {
  const TowerSelect(this.tower);

  final Tower? tower;
}

/// Forces UI rebuilds when the selected tower mutates in-place
/// (e.g. `tower.levelUp()` changes damage/fireRate but the selected
/// instance stays the same).
class RefreshSelectedTower extends GameEvent {
  const RefreshSelectedTower();
}
