// import 'dart:async';

// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_face_verification/img_utils.dart';

// import 'package:get/get.dart';
// import 'package:tflite/tflite.dart';

// class LiveController extends GetxController {
//   var predicted = "".obs;
//   var lastPredicted = "";
//   var modelReady = false.obs;
//   late CameraController cameraController;
//   var cameraInitialized = false.obs;
//   var captured = false.obs;
//   var predicting = false;
//   var memImg;
//   loadModel() async {
//     await Tflite.loadModel(
//         model: 'assets/face/model_unquant.tflite',
//         labels: 'assets/face/labels.txt');
//     modelReady(true);
//   }

//   initializeCamera() async {
//     loadModel();
//     List<CameraDescription> cameras = await availableCameras();
//     cameraController = CameraController(cameras[1], ResolutionPreset.medium);
//     await cameraController.initialize().then((_) {
//       cameraInitialized(true);

//       cameraController.startImageStream((image) {
//         if (!captured.value) {
//           runModel(image);
//         } else {
//           cameraController.stopImageStream();
//           cameraController.dispose();
//           cameraInitialized(false);
//         }
//       });
//     });
//   }

//   runModel(CameraImage image) async {
//     if (predicting)
//       return;
//     else {
//       predicting = true;
//       var predictions = await Tflite.runModelOnFrame(
//         bytesList: image.planes.map((plane) {
//           return plane.bytes;
//         }).toList(),
//         imageHeight: image.height,
//         imageWidth: image.width,
//         imageMean: 127.5,
//         imageStd: 127.5,
//         rotation: 90,
//         numResults: 1,
//         threshold: .1,
//         asynch: true,
//       );
//       predicting = false;
//       predictions!.forEach((element) {
//         // if (element["index"] == 0 && element['confidence'] > 70)
//         {
//           lastPredicted = element['label'];

//           predicted(element['label']);
//           // takePicture(image);
//         }
//         print(element);
//       });
//     }
//   }

//   takePicture(CameraImage image) async {
//     var timer = Timer.periodic(1.seconds, (timer) async {
//       if (timer.tick > 2) {
//         if (predicted.value == lastPredicted) {
//           print(timer.tick);
//           timer.cancel();
//           var img = await convertYUV420toImageColor(image, rotate: true);
//           memImg = img;
//           captured(true);
//         }
//       } else {}
//     });
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     initializeCamera();
//   }
// }

// class Liveliness extends StatelessWidget {
//   Liveliness({Key? key}) : super(key: key);
//   final controller = Get.put(LiveController());
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Obx(() => controller.cameraInitialized.value
//               ? Center(child: CameraPreview(controller.cameraController))
//               : const Center(child: CircularProgressIndicator())),
//           Obx(() => controller.captured.value
//               ? Image.memory(controller.memImg)
//               : const SizedBox()),
//           // Obx(() => Center(
//           //       child: Text(
//           //         "TESTING" + controller.predicted.value,
//           //         style: Theme.of(context)
//           //             .textTheme
//           //             .titleMedium!
//           //             .copyWith(color: Colors.white, shadows: <Shadow>[
//           //           const Shadow(
//           //             offset: Offset(1.0, 1.0),
//           //             blurRadius: 3.0,
//           //             color: Color.fromARGB(255, 0, 0, 0),
//           //           ),
//           //           const Shadow(
//           //             offset: Offset(1.5, 1.5),
//           //             blurRadius: 3.0,
//           //             color: Color.fromARGB(255, 193, 16, 16),
//           //           ),
//           //         ]),
//           //       ),
//           //     ))
//         ],
//       ),
//     );
//   }
// }
