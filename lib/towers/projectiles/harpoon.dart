import 'package:td/towers/projectiles/projectile.dart';

class Harpoon extends Projectile {
  Harpoon({
    required super.speed,
    required super.damage,
    required super.windResist,
  }) : super(name: 'Harpoon', impactType: ImpactType.normal);
}
