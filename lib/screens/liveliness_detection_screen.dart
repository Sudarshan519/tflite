import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_verification/captured_image.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
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

  var predictionTime = 0;
  var timeStamp = 0;
  var runtime = 0;
  var image;
  var detected;
  var eye = '';
  final MainController controller = Get.find();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeCamera();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_eyes.tflite', labels: 'assets/labels_eyes.txt');

    modelReady = true;
    setState(() {});
  }

  takePicture(cameraImage) async {
    loading = true;

    image = await convertYUV420toImageColor(cameraImage);
    cameraController.dispose();
    cameraInitialized = false;
    controller.nextPage();
    if (mounted) setState(() {});
  }

  initializeCamera() async {
    loadModel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(cameras[1], ResolutionPreset.low);
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
    // controller.nextPage();
    return Scaffold(
      body: Stack(children: [
        if (cameraInitialized) CameraPreview(cameraController),
        Center(
            child: Text(
          blinkDetected ? "Blink Detected" : "",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.white, shadows: <Shadow>[
            const Shadow(
              offset: Offset(1.0, 1.0),
              blurRadius: 3.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            const Shadow(
              offset: Offset(1.5, 1.5),
              blurRadius: 3.0,
              color: Color.fromARGB(255, 193, 16, 16),
            ),
          ]),
        )),
        if (image != null) Image.memory(image),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(eye),
            Text(detectedBlinks.toString()),
            Text("Delay"),
            Text(predictionTime.toString())
          ]),
        )
      ]),
    );
  }

  void runModel(CameraImage image) async {
    // isPredicting = true;
    timeStamp = DateTime.now().millisecondsSinceEpoch;

    // });
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

      predictions!.forEach((element) {
        print(element.toString() + "LOG EYE");
        eye = element['label'];
        // if (element['label'] == '1 Eyes Closed')

        if (element['confidence'] > .30 &&
            element['label'] != "2 Not Detected") {
          // print(element);
          if (detected != element['label']) {
            print(element.toString() + "LOG EYE");
            // takePicture(image);
            detected = element['label'];
            detectedBlinks.add(element.toStringAsFixed(2));
            if (detectedBlinks.length > 2) takePicture(image);

            blinkDetected = true;
            setState(() {});
          }
        } else {
          print("Not Detected" + "LOG EYE");
          Future.delayed(
              const Duration(
                seconds: 3,
              ), () {
            blinkDetected = false;
            if (mounted) setState(() {});
          });
        }
      });
      isPredicting = false;
    } catch (e) {
      print(e.toString());
    }
  }
}
