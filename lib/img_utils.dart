import 'dart:io';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

// imglib.Image convertYUV420ToImage(CameraImage cameraImage) {
//   final width = cameraImage.width;
//   final height = cameraImage.height;

//   final yRowStride = cameraImage.planes[0].bytesPerRow;
//   final uvRowStride = cameraImage.planes[1].bytesPerRow;
//   final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

//   final image = imglib.Image(width, height);

//   for (var w = 0; w < width; w++) {
//     for (var h = 0; h < height; h++) {
//       final uvIndex =
//           uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
//       final index = h * width + w;
//       final yIndex = h * yRowStride + w;

//       final y = cameraImage.planes[0].bytes[yIndex];
//       final u = cameraImage.planes[1].bytes[uvIndex];
//       final v = cameraImage.planes[2].bytes[uvIndex];

//       image.data[index] = yuv2rgb(y, u, v);
//     }
//   }
//   return image;
// }

// int yuv2rgb(int y, int u, int v) {
//   // Convert yuv pixel to rgb
//   var r = (y + v * 1436 / 1024 - 179).round();
//   var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
//   var b = (y + u * 1814 / 1024 - 227).round();

//   // Clipping RGB values to be inside boundaries [ 0 , 255 ]
//   r = r.clamp(0, 255);
//   g = g.clamp(0, 255);
//   b = b.clamp(0, 255);

//   return 0xff000000 | ((b << 16) & 0xff0000) | ((g << 8) & 0xff00) | (r & 0xff);
// }

const shift = (0xFF << 24);
convertYUV420toImageColor(CameraImage image, {bool rotate = false}) async {
  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int? uvPixelStride = image.planes[1].bytesPerPixel;

    // imgLib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = shift | (b << 16) | (g << 8) | r;
      }
    }

    if (Platform.isAndroid) img = imglib.copyRotate(img, rotate ? -90 : 90);

    ///trim rect
    if (!rotate) {
      /// TODO: DYNAMIC CROP ON IMAGE ACC/ TO DEVICE CAMERA
      ///
      ///
      // List<int> trimRect;
      // var img1 = imglib.Image(400, 200);
      // trimRect = findTrim(img1, mode: TrimMode.transparent, sides: Trim.all);

      ///480 /680
      // var cropSizeX = 420;
      // var cropSizeY = 300;

      // var minSize = min(img.width, img.height);
      // var ratio = img.height / img.width;

      // // img.width - min(img.width, img.height) ~/ 3;

      //  LAST APK
      // var decodedImage = img;
      // var cropSize = min(decodedImage.width, decodedImage.height);
      // int offsetX =
      //     (decodedImage.width - min(decodedImage.width, decodedImage.height)) ~/
      //         20;
      // int offsetY = (decodedImage.height -
      //         min(decodedImage.width, decodedImage.height)) ~/
      //     1;
      // img = imglib.copyCrop(img, offsetX, offsetY, 420, 300);
      //  LAST APK
      // var offSetX =
      // (20 * img.width ~/ 420); //(image.width - minSize) ~/ 2; // 20;
      // var offSetY = 120 * image.height ~/ 300; //(img.height - minSize) ~/ 2;
      // img = imglib.copyCrop(img, offsetX, offsetY, 420, 300);
      // img = imglib.copyCrop(img, offSetX, offSetY, 500, 320);
      // img = imglib.copyCrop(img, offSetX, offSetY, cropSizeX, cropSizeY);

      img = imglib.copyCrop(img, 40, 180, 420, 300);
    }

    imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);

    List<int> png = pngEncoder.encodeImage(img);
    // muteYUVProcessing = false;
    return (png);
  } catch (e) {
    // print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  // return null;
}
