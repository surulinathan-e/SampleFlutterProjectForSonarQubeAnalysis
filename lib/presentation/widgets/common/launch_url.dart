import 'package:url_launcher/url_launcher.dart';

import '../../../utils/logger.dart';

launchURL(String urlPath) async {
  Uri url = Uri.parse(urlPath);
  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Logger.printLog('Could not launch $url');
    }
  } catch (error) {
    Logger.printLog(error.toString());
  }
}
