import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sensors_plus/sensors_plus.dart';
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
  bool nextPage = false;

  var predictionTime = 0;
  var timeStamp = 0;
  var runtime = 0;
  var cameraImage;
  var image;
  var detected = false;
  var eyesClosed = false;
  var blinks = 0;
  var eyesOpen = false;
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  int x = 0, y = 0, z = 0;
  var eye;
  final MainController controller = Get.put(MainController());

  int blinkTimeStamp = 0;
  var predict;
  @override
  void initState() {
    super.initState();
    initializeCamera();
    _streamSubscriptions.add(accelerometerEvents.listen(
      (data) {
        checkAngle(data);
      },
    ));
  }

  void checkAngle(AccelerometerEvent data) {
    if (x == data.x.round() && y == data.y.round() && z == data.z.round()) {
      if (detectedBlinks.isNotEmpty) {
        // if (cameraImage != null) takePicture(cameraImage);
      }
    } else {
      x = data.x.round();
      y = data.y.round();
      z = data.z.round();
      clearBlinks();
    }
  }

  /// clear blinks
  clearBlinks() {
    eye = "";
    Future.delayed(2.seconds, () {
      eyesClosed = false;
      detected = false;
      if (mounted) setState(() {});
    });
    detected = false;
    detectedBlinks.clear();
    setState(() {});
  }

  /// load tflite model
  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/eye3/model_unquant.tflite',
        labels: 'assets/eye1/labels.txt');

    modelReady = true;
    setState(() {});
  }

  /// take picture
  takePicture(cameraImage) async {
    // loading = true;

    // image = await convertYUV420toImageColor(cameraImage);
    // cameraController.dispose();
    // cameraInitialized = false;
    // if (mounted) setState(() {});
    // loading = false;
    if (!nextPage) controller.nextPage();
    nextPage = true;
  }

  /// initialize camera module and load model
  initializeCamera() async {
    await loadModel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(cameras[1], ResolutionPreset.ultraHigh);
    await cameraController.initialize();
    cameraInitialized = true;

    setState(() {});
    await cameraController.startImageStream((image) {
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
  }

  // runModelOnImage() async {
  //   var image = await ImagePicker().pickImage(source: ImageSource.gallery);
  //   var predictions = await Tflite.runModelOnImage(path: image!.path);
  //   print(predictions!.first);
  // }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: Stack(children: [
            if (cameraInitialized)
              Center(child: CameraPreview(cameraController)),
            Center(
              child: AnimatedContainer(
                duration: 600.milliseconds,
                child: detected
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
              ),
            ),
            if (detected)
              Center(
                child: SizedBox(
                    height: 304,
                    width: 304,
                    child: Image.asset(eyesClosed
                        ? "assets/images/face_mark_eyes_close.webp"
                        : "assets/images/face_mark_eyes_open.webp")),
              ),
            // if (detected)
            //   Text(
            //     eyesClosed ? "EYES CLOSED" : "EYES OPEN",
            //     style: const TextStyle(color: Colors.white),
            //   ),
            // if (image != null) Image.memory(image),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: Column(mainAxisSize: MainAxisSize.min, children: [
            //     Text(
            //       predict.toString(),
            //       style: TextStyle(color: Colors.white),
            //     ),
            //     Text(
            //       eye.toString(),
            //       style: const TextStyle(color: Colors.white),
            //     ),
            //     Obx(() => Text(
            //           controller.blinks.toString(),
            //           style: const TextStyle(color: Colors.white),
            //         )),
            //     const Text("Delay"),
            //     Text(predictionTime.toString())
            //   ]),
            // ),
            // ElevatedButton(
            //     onPressed: () {
            //       cameraController.dispose();
            //       runModelOnImage();
            //     },
            //     child: Text("PickImage"))
          ]),
        ),
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
      predict = predictions;

      var currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
      predictionTime = currentTimeStamp - timeStamp;

      var element = predictions!.first;
      print(element);

      // if (element != detectedBlinks.last) {
      //   detected = true;
      // }
      if (element['index'] == 0) {
        detected = true;
        eyesOpen = true;
        if (mounted) setState(() {});
      } else if (element['index'] == 1) {
        if (eyesOpen) {
          detected = true;
          addBlink(element);
        }
      } else {
        detected = false;
        if (mounted) setState(() {});
      }

      {
        //   if (element['label'] == "2 Error") {
        //     eye = element['label'];
        //     detected = false;
        //     eyesClosed = false;
        //     setState(() {});
        //   } else if (element['label'] == "0 Eyes Open") {
        //     blinkTimeStamp = DateTime.now().millisecondsSinceEpoch;
        //     eye = element['label'];
        //     if (!eyesClosed) {
        //       detected = true;
        //       eyesClosed = false;
        //       setState(() {});
        //     }
        //   } else {
        //     eye = element['label'];
        //     print("CLOSED");
        //     print(element);
        //     eyesClosed = true;
        //     // Future.delayed(3.seconds, () {
        //     //   eyesClosed = false;
        //     // });
        //     setState(() {});
        //     // Future.delayed(2.seconds, () {
        //     //   setState(() {
        //     //     eyesClosed = false;
        //     //   });
        //     // });

        //     // addBlink(element);
        //     eye = element['label'];
        //   }
        //   setState(() {});
        // if (element['label'] != "2 Error") {
        //   if (element['confidence'] > .50) {
        //     if (eye != null && eye != element['label']) {
        //       eye = element['label'];

        //       if ((DateTime.now().millisecondsSinceEpoch - blinkTimeStamp) >
        //           2000) {
        //         blinkTimeStamp = DateTime.now().millisecondsSinceEpoch;
        //         cameraImage = image;
        //         addBlink(element);
        //       }
        //     }

        //     if (element['label'] == "0 Eyes Open") {
        //       eye = "Blink Detected";

        //       Future.delayed(const Duration(seconds: 1), () {
        //         eye = "";
        //       });
        //       blinkDetected = true;
        //     }
        //     // else {
        //     //   eye = "";
        //     //   detectedBlinks.add(element);
        //     //   blinkDetected = false;
        //     // }
        //     if (mounted) setState(() {});
        //     // if (detected != element['label']) {
        //     //   // takePicture(image);
        //     //   detected = element['label'];
        //     //   if (detectedBlinks.length > 10) {
        //     //     takePicture(image);
        //     //   }
        //     // }
        //   }
        // }

        // /// ERROR CASE OR LOW CONFIDENCE
        // else {
        //   // clearBlinks();

        //   // Future.delayed(
        //   //     const Duration(
        //   //       seconds: 3,
        //   //     ), () {
        //   //   blinkDetected = false;
        //   // });
        // }
      }
      isPredicting = false;
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  void addBlink(element) {
    controller.blinks = controller.blinks + 1;
    detectedBlinks.add(element);
    if (detectedBlinks.length > 1) {
      takePicture(image);
    } else {
      detectedBlinks.add(element);
    }
    if (mounted) setState(() {});
  }
}
