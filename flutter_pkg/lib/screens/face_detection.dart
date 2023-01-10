
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_pkg/const/strings.dart';
import 'package:flutter_pkg/controller/main_controller.dart';
import 'package:flutter_pkg/utils/img_utils.dart';
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
  var nextPage = false;
  var cameraImage;
  final MainController controller = Get.find();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeCamera();
  }

  initializeCamera() async {
    await loadModel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(cameras[1], ResolutionPreset.medium);
    await cameraController.initialize().then((_) {});
    cameraInitialized = true;
    setState(() {});
    cameraController.startImageStream((image) {
      if (!captured) {
        runModel(image);
      } else {
        cameraInitialized = false;
        if (mounted) setState(() {});
      }
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: TModels.SELFIE_MODEL
        // "assets/face/model_unquant.tflite",
        // 'assets/model_face.tflite'
        ,
        labels: 'assets/labels_face.txt');

    modelReady = true;
    setState(() {});
  }

  takePicture(cameraImage) async {
    loading = true;
    captured = true;
    if (mounted) setState(() {});
    var image = await convertYUV420toImageColor(cameraImage, rotate: true);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    var file = File(
        "${appDocPath + DateTime.now().millisecondsSinceEpoch.toString()}.png");
    await file.writeAsBytes(image);
    path = file.path;
    controller.selfie(path);

    Future.delayed(Duration.zero, () {
      loading = false;
      if (mounted) setState(() {});
    });
    if (!nextPage) controller.nextPage();
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
    var element = predictions!.first;
    // for (var element in predictions!)
    {
      if (element['confidence'] > .80 &&
          element['label'] == "0 Face Detected") {
        faceDetected = true;
        cameraImage = image;
        // if (!timerInitialized) {
        //   timer = Timer.periodic(const Duration(seconds: 2), (t) {
        //     if (faceDetected) {
        //       if (value == 2) {
        //         if (!captured) takePicture(image);
        //         t.cancel();
        //         timer.cancel();
        //       } else {
        //         value++;
        //         if (mounted) setState(() {});
        //       }
        //     } else {
        //       t.cancel();
        //       timer.cancel();
        //       value = 0;
        //     }
        //   });
        // } else {
        //   if (timerInitialized && captured) {
        //     timer.cancel();
        //   }
        // }
        if (mounted) setState(() {});
      } else {
        if (timerInitialized) timer.cancel();
        value = 5;
        if (faceDetected) faceDetected = false;
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(children: [
          // camera
          if (!captured)
            if (cameraInitialized)
              Center(child: CameraPreview(cameraController)),
          //face bounding box
          if (!captured)
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
          // Center(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       border: Border.all(
          //           width: 2, color: faceDetected ? Colors.green : Colors.grey),
          //     ),
          //     height: 404,
          //     width: 304,
          //     child: Text(value.toString()),
          //   ),
          // )
          else
            loading
                ? const CircularProgressIndicator()
                : Image.file(File(path)),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: InkWell(
                onTap: () {
                  takePicture(cameraImage);
                },
                child: Image.asset(
                  faceDetected
                      ? "assets/images/camera_button_active.webp"
                      : "assets/images/camera_button_inactive.webp",
                  height: 60,
                  width: 60,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
