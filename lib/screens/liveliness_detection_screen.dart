import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_verification/captured_image.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:get/get.dart';
import 'package:tflite/tflite.dart';

class LivelinessDetection extends StatefulWidget {
  const LivelinessDetection({Key? key}) : super(key: key);

  @override
  State<LivelinessDetection> createState() => _LivelinessDetectionState();
}

class _LivelinessDetectionState extends State<LivelinessDetection> {
  late CameraController cameraController;
  bool cameraInitialized = false;
  bool modelReady = false;
  bool isPredicting = false;
  bool faceDetected = false;
  bool liveliness = false;
  bool captured = false;
  var detectedBlinks = [];
  late Timer timer;
  var value = 0;
  bool timerInitialized = false;
  var path = "";
  var loading = false;
  var blinkDetected = false;
  bool nextPage = false;

  var predictionTime = 0;
  var timeStamp = 0;
  var runtime = 0;
  var image;
  var detected;
  var blinks = 0;

  var eye = 'Not Detected';
  final MainController controller = Get.put(MainController()); // Get.find();
  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/eye1/model_unquant.tflite',
        labels: 'assets/eye1/labels.txt');

    modelReady = true;
    setState(() {});
  }

  takePicture(cameraImage) async {
    loading = true;

    image = await convertYUV420toImageColor(cameraImage);
    cameraController.dispose();
    cameraInitialized = false;
    if (mounted) setState(() {});
    loading = false;
    if (!nextPage) controller.nextPage();
    nextPage = true;
  }

  initializeCamera() async {
    loadModel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(cameras[1], ResolutionPreset.medium);
    await cameraController.initialize().then((_) {
      cameraInitialized = true;

      setState(() {});
      cameraController.startImageStream((image) {
        if (!captured) {
          if (isPredicting) {
            return;
          } else {
            if (mounted) runModel(image);
          }
        } else {
          cameraController.stopImageStream();
          cameraController.dispose();
          cameraInitialized = false;
          if (mounted) setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(children: [
          if (cameraInitialized) Center(child: CameraPreview(cameraController)),
          Center(
              child: AnimatedContainer(
            duration: 600.milliseconds,
            child: eye == "Blink Detected"
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
          )),
          Center(
            child: SizedBox(
                height: 304,
                width: 304,
                child: Image.asset(eye != "Blink Detected"
                    ? "assets/images/face_mark_eyes_close.webp"
                    : "assets/images/face_mark_eyes_open.webp")),
          ),
          if (image != null) Image.memory(image),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Obx(() => Text(controller.blinks.toString())),
              const Text("Delay"),
              Text(predictionTime.toString())
            ]),
          )
        ]),
      ),
    );
  }

  void runModel(CameraImage image) async {
    isPredicting = true;
    timeStamp = DateTime.now().millisecondsSinceEpoch;

    try {
      var predictions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: .1,
        asynch: true,
      );
      var currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
      predictionTime = currentTimeStamp - timeStamp;

      for (var element in predictions!) {
        print(element);
        if (element['confidence'] > .50 && element['label'] != "2 Error") {
          if (detected != element['label']) {
            controller.blinks = controller.blinks + 1;
            if (detectedBlinks.length > 5) {
              takePicture(image);
            }
            detectedBlinks.add(element);

            setState(() {});
          }
          detected = element['label'];

          if (element['label'] == "0 Eyes Open") {
            eye = "Blink Detected";
            // blinks++;
            // if (blinks > 4) {
            //   takePicture(image);
            // }
            Future.delayed(const Duration(seconds: 1), () {
              eye = "";
            });
            blinkDetected = true;
          } else {
            eye = "";
            blinkDetected = false;
          }
          if (mounted) setState(() {});
          if (detected != element['label']) {
            // takePicture(image);
            detected = element['label'];
            if (detectedBlinks.length > 10) {
              takePicture(image);
            }
          }
        } else {
          Future.delayed(
              const Duration(
                seconds: 3,
              ), () {
            blinkDetected = false;
          });
        }
      }
      isPredicting = false;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
