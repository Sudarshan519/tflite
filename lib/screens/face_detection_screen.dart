import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_verification/captured_image.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

class FaceDetection extends StatefulWidget {
  const FaceDetection({Key? key}) : super(key: key);

  @override
  State<FaceDetection> createState() => _FaceDetectionState();
}

class _FaceDetectionState extends State<FaceDetection> {
  late CameraController cameraController;
  bool cameraInitialized = false;
  bool modelReady = false;
  bool isPredicting = false;
  bool faceDetected = false;
  bool liveliness = false;
  bool captured = false;
  late Timer timer;
  var value = 0;
  bool timerInitialized = false;
  var path = "";
  var loading = false;
  final MainController controller = Get.find();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeCamera();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_face.tflite', labels: 'assets/labels_face.txt');

    modelReady = true;
    setState(() {});
  }

  takePicture(cameraImage) async {
    loading = true;
    setState(() {});
    var image = await convertYUV420toImageColor(cameraImage);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    // print(appDocPath);
    var file = File(
        "${appDocPath + DateTime.now().millisecondsSinceEpoch.toString()}.png");
    await file.writeAsBytes(image);
    path = file.path;
    controller.selfie(path);
    controller.nextPage();
    cameraController.dispose();
    Future.delayed(Duration.zero, () {
      loading = false;
      setState(() {});
    });
  }

  initializeCamera() async {
    // setState(() {});
    loadModel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(cameras[1], ResolutionPreset.medium);
    await cameraController.initialize().then((_) {
      cameraInitialized = true;

      setState(() {});
      cameraController.startImageStream((image) {
        if (!captured) {
          runModel(image);
        } else {
          cameraController.stopImageStream();
          cameraController.dispose();
          cameraInitialized = false;
          setState(() {});
        }
      });
    });
  }

  void runModel(CameraImage image) async {
    if (isPredicting) {
      return;
    } else {
      isPredicting = true;
    }
    var predictions = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      numResults: 1,
      threshold: .1,
      asynch: true,
    );
    isPredicting = false;
    predictions!.forEach((element) {
      if (element['confidence'] > .98 &&
          element['label'] == "0 Face Detected") {
        faceDetected = true;

        if (!timerInitialized) {
          timer = Timer.periodic(const Duration(seconds: 5), (t) {
            if (faceDetected) {
              if (value == 5) {
                captured = true;
                takePicture(image);
                t.cancel();
                timer.cancel();
              } else {
                value++;
              }
            } else {
              t.cancel();
              timer.cancel();
              value = 0;
            }
          });
        } else {
          if (timerInitialized && captured) {
            timer.cancel();
          }
        }

        setState(() {});
      } else {
        if (timerInitialized) timer.cancel();
        value = 5;
        // Future.delayed(const Duration(milliseconds: 100), () {
        // print(element['label']);
        if (faceDetected) faceDetected = false;
        setState(() {});
        // });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // controller.nextPage();
    return Scaffold(
      body: Stack(children: [
        // camera
        if (!captured)
          if (cameraInitialized) CameraPreview(cameraController),
        //face bounding box
        if (!captured)
          Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    width: 2, color: faceDetected ? Colors.green : Colors.grey),
              ),
              height: 304,
              width: 304,
              child: Text(value.toString()),
            ),
          )
        else
          loading ? CircularProgressIndicator() : Image.file(File(path))
      ]),
    );
  }
}
