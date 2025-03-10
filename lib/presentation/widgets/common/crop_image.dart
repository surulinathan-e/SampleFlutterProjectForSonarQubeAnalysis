import 'package:image_cropper/image_cropper.dart';
import '../../../utils/colors/colors.dart';

cropImage(pickedImage) async {
  if (pickedImage != null) {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: white,
          toolbarWidgetColor: black,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            // CropAspectRatioPresetCustom(),
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            // CropAspectRatioPresetCustom(), // IMPORTANT: iOS supports only one custom aspect ratio in preset list
          ],
        ),
        // WebUiSettings(
        //   context: context,
        // ),
      ],
    );
    return croppedFile;
  }
}
