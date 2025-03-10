import 'dart:io';

import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/model/app_config.dart';

Future<void> checkInstalledAppVersion(
    context,
    AppConfig appConfigDetail,
    Function navigateHome,
    organizationId,
    organizationName,
    organizationLatitude,
    organizationLongitude,
    organizationRadius,
    geoLocationEnable,
    {isSigleOrganization = false,
    String title = 'App Update',
    String message = 'recommends that you update to the latest version.',
    String possitiveBtnText = 'Update'}) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String appName = packageInfo.appName;
  String version = packageInfo.version;

  var installedAppVersionSplitArray = version.split('.');
  var appLatestVersionSplitArray = appConfigDetail.appLatestVersion!.split('.');

  String installedAppVersion = installedAppVersionSplitArray[0] +
      installedAppVersionSplitArray[1] +
      installedAppVersionSplitArray[2];

  String appLatestVersion = appLatestVersionSplitArray[0] +
      appLatestVersionSplitArray[1] +
      appLatestVersionSplitArray[2];

  if (int.parse(installedAppVersion) <
      int.parse(appLatestVersion.replaceAll(RegExp('\\(.*?\\)'), ''))) {
    showAlertWithAction(
        context: context,
        title: title,
        content: '$appName $message',
        onPress: () {
          _openAppStore(
              androidAppStoreUrl: appConfigDetail.androidAppStoreUrl,
              iOSAppStoreUrl: appConfigDetail.androidAppStoreUrl);
        },
        possitiveBtnText: possitiveBtnText,
        visibleNegativeBtn: false);
  } else {
    navigateHome(organizationId, organizationName, organizationLatitude,
        organizationLongitude, organizationRadius, geoLocationEnable,
        isSigleOrganization: isSigleOrganization);
  }
}

void _openAppStore(
    {String? androidAppStoreUrl = '', String? iOSAppStoreUrl = ''}) {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      launchURL(Platform.isAndroid ? androidAppStoreUrl! : iOSAppStoreUrl!);
    }
  } catch (error) {
    Logger.printLog(error.toString());
  }
}
