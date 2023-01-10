import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pkg/controller/main_controller.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

class LivelinessMlKit extends StatefulWidget {
  const LivelinessMlKit({Key? key}) : super(key: key);

  @override
  State<LivelinessMlKit> createState() => _LivelinessMlKitState();
}

class _LivelinessMlKitState extends State<LivelinessMlKit> {
  var cameras = [];
  var cameraInitilized = false;
  var blinkCount = 0;
  var faceDetected = false;
  var isRunning = false;
  var blinkDetected = false;
  var isNavigating = false;

  int x = 0, y = 0, z = 0;
  late CameraController controller;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
        enableLandmarks: true,
        enableTracking: true),
  );
  final MainController mainController = Get.find();
  var faceTimeStamp;
  var blinkTimeStamp;
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  @override
  void initState() {
    super.initState();
    initCameraModule();
    _streamSubscriptions.add(accelerometerEvents.listen(
      (data) {
        checkAngle(data);
      },
    ));
  }

  initCameraModule() async {
    cameras = await availableCameras();
    setState(() {});
    var cameraDescirption = cameras[1];
    controller = CameraController(cameraDescirption, ResolutionPreset.high,
        enableAudio: false);
    await controller.initialize().then((_) {
      setState(() {
        cameraInitilized = true;
      });
      controller.startImageStream(runMLModel);
    });
  }

  void checkAngle(AccelerometerEvent data) {
    if (x == data.x.round() &&
        y == data.y.round() &&
        z == data.z.round() &&
        z > .5 &&
        y > 8 &&
        x < 1) {
      if (!isNavigating) {
        if ((blinkTimeStamp - faceTimeStamp) > 100) {
          isNavigating = true;
          vibrate();
          Future.delayed(0.seconds, () {
            // print("BLINK DETECTED");
            mainController.nextPage();
          });
        }
      }
    } else {
      x = data.x.round();
      y = data.y.round();
      z = data.z.round();
      clearBlinks();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (cameraInitilized) Center(child: CameraPreview(controller)),
          // if (blinkDetected)
          Center(
            child: faceDetected
                ? Image.asset(
                    "assets/images/camera_frame_active.webp",
                    height: 380,
                    width: 380,
                  )
                : Image.asset(
                    "assets/images/camera_frame_inactive.webp",
                    height: 380,
                    width: 380,
                  ),
          )
        ],
      ),
    );
  }

  runMLModel(CameraImage image) async {
    if (isRunning) return;
    isRunning = true;
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[1];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (imageRotation == null) return;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) return;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    final faces = await _faceDetector.processImage(inputImage);
    isRunning = false;
    if (faces.isNotEmpty) {
      for (Face face in faces) {
        blinkTimeStamp = DateTime.now().millisecondsSinceEpoch;
        if (kDebugMode) {
          print(face.leftEyeOpenProbability);
        }

        if ((face.leftEyeOpenProbability ?? 99) < .2) {
          blinkDetected = true;
          // if (!isNavigating) {
          //   if ((blinkTimeStamp - faceTimeStamp) > 100) {
          //     isNavigating = true;
          //     vibrate();
          //     Future.delayed(0.seconds, () {
          //       // print("BLINK DETECTED");
          //       mainController.nextPage();
          //     });
          //   }
          // }
        } else {
          faceTimeStamp = DateTime.now().millisecondsSinceEpoch;
          if (faceDetected != true && face.leftEyeOpenProbability! > .2) {
            if (mounted) {
              setState(() {
                faceDetected = true;
              });
            }
          }

          if (kDebugMode) {
            print("FRONT DETECTED");
          }
        }
      }
    } else {
      if (faceDetected != false) {
        setState(() {
          faceDetected = false;
        });
      }
      if (kDebugMode) {
        print("FRONT DETECTED");
      }
    }
    if (kDebugMode) {
      print("NO FACE DETECTED");
    }
  }

  void clearBlinks() {
    faceDetected = false;
    blinkDetected = false;
    blinkCount = 0;
  }
}

void vibrate() async {
  // if (await Vibration.hasCustomVibrationsSupport()) {
  //   Vibration.vibrate(duration: 1000);
  // } else {
  Vibration.vibrate();
  // await Future.delayed(Duration(milliseconds: 500));
  //   Vibration.vibrate();
  // }
}
