import 'package:flame/components.dart';

class Projectile extends Component {
  final String name;
  final double _speed;
  final double _damage;
  final ImpactType impactType;
  final double windResist;

  Projectile({
    required this.name,
    required double speed,
    required double damage,
    required this.impactType,
    required this.windResist,
  }) : assert(speed - windResist > 0),
       _speed = speed,
       _damage = damage;

  double get speed => _speed;
  double get damage => _damage * (_speed - windResist);
}

enum ImpactType { normal, explode, fire, ice, electric }
