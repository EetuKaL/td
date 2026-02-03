// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class SFi extends S {
  SFi([String locale = 'fi']) : super(locale);

  @override
  String get tower => 'Torni';

  @override
  String get damage => 'Vahinko';

  @override
  String get fireRate => 'Tulinopeus';

  @override
  String get spotDistance => 'Havaintoetäisyys';

  @override
  String get cannon => 'Tykki';

  @override
  String towerSelectionTitle(String towerType, int level) {
    return '$towerType (Taso $level)';
  }

  @override
  String upgradeTooltip(int level) {
    return 'Päivitä tasolle $level';
  }

  @override
  String get maxLevelTooltip => 'Maksimitaso';

  @override
  String get closeTooltip => 'Sulje';
}
