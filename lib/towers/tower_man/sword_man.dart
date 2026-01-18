import 'package:td/towers/tower_man/tower_man.dart';

class SwordMan extends TowerMan {
  SwordMan({required super.position, required super.size});

  @override
  static double get walkSpeed => 50.0;
  @override
  static double get range => 15.0;
  @override
  static double get health => 100.0;
  @override
  static double get damage => 10.0;
}
