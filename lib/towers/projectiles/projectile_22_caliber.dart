import 'package:td/towers/projectiles/projectile.dart';

class Projectile22Caliber extends Projectile {
  Projectile22Caliber({required super.speed})
    : super(
        name: '22 Caliber Bullet',
        damage: 2.0,
        windResist: 20.0,
        impactType: ImpactType.normal,
      );
}
