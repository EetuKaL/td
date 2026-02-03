// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get tower => 'Tower';

  @override
  String get damage => 'Damage';

  @override
  String get fireRate => 'Fire rate';

  @override
  String get spotDistance => 'Spot distance';

  @override
  String get cannon => 'Cannon';

  @override
  String towerSelectionTitle(String towerType, int level) {
    return '$towerType (Lv $level)';
  }

  @override
  String upgradeTooltip(int level) {
    return 'Upgrade to Lv $level';
  }

  @override
  String get maxLevelTooltip => 'Max level';

  @override
  String get closeTooltip => 'Close';
}
