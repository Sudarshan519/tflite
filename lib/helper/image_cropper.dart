import 'package:image_cropper/image_cropper.dart';

Future<String> cropImage(String path) async {
  var now = DateTime.now().millisecondsSinceEpoch;
  CroppedFile? croppedFile = await ImageCropper.platform.cropImage(
      sourcePath: path, aspectRatioPresets: [CropAspectRatioPreset.ratio3x2]);
  var totalTime = DateTime.now().millisecondsSinceEpoch - now;
  print("total time to crop $totalTime");
  return croppedFile!.path;
}
