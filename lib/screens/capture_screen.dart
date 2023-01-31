import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_verification/const/strings.dart';
import 'package:flutter_face_verification/img_utils.dart';
import 'package:flutter_face_verification/screens/liveliness_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:get/get.dart';
import 'package:tflite/tflite.dart';

class CaptureImage extends StatefulWidget with WidgetsBindingObserver {
  const CaptureImage({Key? key, required this.type}) : super(key: key);
  final String type;
  @override
  State<CaptureImage> createState() => _CaptureImageState();
}

class _CaptureImageState extends State<CaptureImage> {
  late CameraController cameraController;
  bool isInitialized = false;
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  final MainController controller = Get.find();

  ///accelerometer values
  ///
  int x = 0;
  int y = 0;
  int z = 0;
  int timeStamp = 0;
  int maxDelay = 0;

  var label = "";
  var phone = "";
  bool isCapturing = false;
  bool isRunning = false;
  bool modelReady = false;
  bool isDetected = false;
  var image;

  late Timer timer;
  bool timerInitialized = false;
  var value = 0;
  bool captured = false;

  getAvailableCamera() async {
    loadmodel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(
        widget.type == "SelfieCapture" ? cameras[1] : cameras[0],
        ResolutionPreset.medium,
        enableAudio: false);
    await cameraController.initialize();
    isInitialized = true;
    if (modelReady) {
      cameraController.startImageStream(runModelOnAvailableImage);
    }

    setState(() {});
  }

  runModelOnAvailableImage(cameraImage) {
    image = cameraImage;
    if (isRunning) {
      return;
    } else {
      if (modelReady) {
        if (cameraImage != null) {
          if (mounted) {
            runmodelonImage(cameraImage);
          }
        }
      }
    }
  }

  loadmodel() async {
    var path = widget.type == AppStrings.FRONT
        ? TModels.FRONT_MODEL
        : widget.type == AppStrings.BACK
            ? 'assets/back_rc/model_unquant.tflite'
            : widget.type == AppStrings.TILTED
                ? 'assets/tilted/model_unquant.tflite'
                : 'assets/model_unquant.tflite';
    var labels = widget.type == AppStrings.FRONT
        ? 'assets/front/labels.txt'
        : widget.type == AppStrings.BACK
            ? 'assets/back/labels.txt'
            : widget.type == AppStrings.TILTED
                ? 'assets/tilted/labels.txt'
                : 'assets/labels.txt';
    // print(path + label);
    await Tflite.loadModel(model: path, labels: labels);

    modelReady = true;
    setState(() {});
  }

  //run model on image
  runmodelonImage(CameraImage image) async {
    if (mounted) {
      setState(() {
        isRunning = true;
      });
    }
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
      if (mounted) {
        setState(() {
          isRunning = false;
        });
      }
      var element = predictions!.first;
      // for (var element in predictions ?? [])

      if (element['confidence'] > .50) {
        if (widget.type == AppStrings.FRONT && element['label'] == "0 Front") {
          if (label == "0 Front") {
            if (!timerInitialized) {
              startTimer();
            }
          }
          if (label != element['label']) {
            isDetected = true;
            if (mounted) {
              setState(() {
                label = element['label'];
              });
            }
          }
        } else if (widget.type == AppStrings.BACK &&
            element['label'] == "0 Back") {
          if (label == "0 Back") {
            if (!timerInitialized) {
              startTimer();
            }
          }
          if (label != element['label']) {
            isDetected = true;
            if (mounted) {
              setState(() {
                label = element['label'];
              });
            }
          }
        } else if (widget.type == AppStrings.TILTED &&
            element['label'] == "1 Tilted") {
          if (label == "1 Tilted") {
            if (!timerInitialized) {
              startTimer();
            }
          }
          if (label != element['label']) {
            isDetected = true;
            if (mounted) {
              setState(() {
                label = element['label'];
              });
            }
          }
        } else {
          clearDetection();
        }
      }
    } catch (e) {}
  }

  clearDetection() {
    label = "";
    if (label != "") {
      if (timerInitialized) {
        timerInitialized = false;
        timer.cancel();
      }
      isDetected = false;
      if (mounted) {
        setState(() {
          label = "";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(accelerometerEvents.listen((data) {
      checkAngle(data);
    }));
    getAvailableCamera();
  }

  startTimer() {
    if (!timerInitialized) {
      timer = Timer.periodic(500.milliseconds, (t) {
        if (value > 2) {
          takePicture(image);
          timer.cancel();
        } else {
          value++;
        }
        setState(() {});
      });
    }

    timerInitialized = true;
    setState(() {});
  }

  resetTimer() {
    timer.cancel();
    timerInitialized = false;
    value = 0;
  }

  checkAngle(AccelerometerEvent data) {
    if (x == data.x.round() && y == data.y.round() && z == data.z.round()) {
      if (timerInitialized) {}
    } else {
      x = data.x.round();
      y = data.y.round();
      z = data.z.round();
      clearDetection();
    }
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  /// TAKE PICTURE ON IMAGESTREAM
  takePicture(cameraImage) async {
    if (!captured) {
      var image = await convertYUV420toImageColor(cameraImage);
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      var file = File(
          "${appDocPath + DateTime.now().millisecondsSinceEpoch.toString()}.png");
      await file.writeAsBytes(image);

      widget.type == AppStrings.FRONT
          ? controller.frontImage(file.path)
          : widget.type == AppStrings.BACK
              ? controller.backImage(file.path)
              : widget.type == AppStrings.TILTED
                  ? controller.tilted(file.path)
                  : controller.selfie(file.path);
      timer.cancel();
      vibrate();
      controller.nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.black,
          child: Stack(alignment: Alignment.center, children: [
            if (isInitialized)

              // Center(
              //   child: AspectRatio(
              //     aspectRatio: 1 / .6,
              //     child: ClipRect(
              //       child: Transform.scale(
              //         scale: cameraController.value.aspectRatio / .6,
              //         child: Center(
              //           child: CameraPreview(cameraController),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              ...[
              Center(
                child: CameraPreview(cameraController),
              ),
              BoundingBox(widget: widget, label: label, phone: phone),
            ]
          ]),
        ),
      ),
    );
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        cameraController.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!cameraController.value.isStreamingImages) {
          await cameraController.startImageStream(runModelOnAvailableImage);
        }
        break;
      default:
    }
  }
}

/// Individual Bounding Box
class BoundingBox extends StatelessWidget {
  const BoundingBox({
    Key? key,
    required this.widget,
    required this.label,
    required this.phone,
  }) : super(key: key);

  final CaptureImage widget;
  final String label;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, .01)
          ..rotateX(widget.type == AppStrings.TILTED ? -.15 : 0),
        alignment: FractionalOffset.center,
        child: Container(
          height: 230,
          width: 340,
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                  width: (label != "" ||
                          phone == 'portrait' ||
                          phone == '45 degree')
                      ? 3
                      : 1.5,
                  color: (phone == 'portrait' || phone == '45 degree')
                      ? Colors.green
                      : label != ""
                          ? Colors.green
                          : Colors.grey)),
        ),
      ),
    );
  }
}
