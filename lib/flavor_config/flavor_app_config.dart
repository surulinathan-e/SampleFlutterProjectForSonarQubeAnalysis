
import './constants/flavors.dart';

class FlavorAppConfig {
  static Flavor appFlavor = Flavor.dev;

  static String get appName => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'TaskO - Dev';
      case Flavor.prod:
        return 'TaskO';
    }
  }
}
