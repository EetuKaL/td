import 'package:td/l10n/generated/app_localizations.dart';

enum TowerType { cannon }

extension TowerTypeL10n on TowerType {
  String localizedName(S s) {
    switch (this) {
      case TowerType.cannon:
        return s.cannon;
    }
  }
}
