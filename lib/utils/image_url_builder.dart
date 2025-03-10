import '../data/network/api/constant/endpoints.dart';

class ImageUrlBuilder {
  static String getImage(String imagePath) {
    return '${Endpoints.imageBaseUrl}/$imagePath';
  }

  static String getVideo(String videoPath) {
    return '${Endpoints.imageBaseUrl}/$videoPath';
  }
}
