import './flavor_config/constants/flavors.dart';
import './flavor_config/flavor_app_config.dart';
import './main.dart';

void main() {
  FlavorAppConfig.appFlavor = Flavor.prod;
  mainApp();
}
