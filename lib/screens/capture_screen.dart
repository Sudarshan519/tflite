import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_face_verification/captured_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:get/get.dart';
import 'package:tflite/tflite.dart';

class CaptureImage extends StatefulWidget {
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

  ///acceleremeter center value
  var acc_center_x = 0;
  var acc_center_y = 0;
  var acc_center_z = 0;
  var label = "";
  var phone = "";
  bool isCapturing = false;
  bool isRunning = false;
  bool modelReady = false;
  bool isDetected = false;
  var image;

  late Timer timer;
  getAvailableCamera() async {
    loadmodel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(
        widget.type == "SelfieCapture" ? cameras[1] : cameras[0],
        ResolutionPreset.medium);
    cameraController.initialize().then((_) {
      isInitialized = true;
      if (modelReady) {
        cameraController.startImageStream(runModelOnAvailableImage);
      }

      setState(() {});
    });
  }

  runModelOnAvailableImage(cameraImage) {
    image = cameraImage;
    if (isRunning) {
      return;
    } else {
      if (modelReady) if (mounted) runmodelonImage(cameraImage);
    }
  }

  loadmodel() async {
    var path = widget.type == "FrontCapture"
        ? 'assets/front/model_unquant.tflite'
        // : widget.type == "BackCapture"
        //     ? 'assets/back/model_unquant.tflite'
        : widget.type == "TiltedImage"
            ? 'assets/tilted/model_unquant.tflite'
            : 'assets/model_unquant.tflite';
    var labels = widget.type == "FrontCapture"
        ? 'assets/front/labels.txt'
        // : widget.type == "BackCapture"
        //     ? 'assets/front/labels.txt'
        : widget.type == "TiltedImage"
            ? 'assets/tilted/labels.txt'
            : 'assets/labels.txt';
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
      for (var element in predictions ?? []) {
        if (element['confidence'] > .90) {
          print(element);
          if (widget.type == "FrontCapture" && element['label'] == "0 Front") {
            if (label != element['label']) {
              isDetected = true;
              if (mounted) {
                setState(() {
                  label = element['label'];
                });
              }
            }
          } else if (widget.type == "BackCapture" &&
              element['label'] == "1 Back") {
            if (label != element['label']) {
              isDetected = true;
              if (mounted) {
                setState(() {
                  label = element['label'];
                });
              }
            }
          } else if (widget.type == "TiltedImage" &&
              element['label'] == "2 Tilted") {
            if (label != element['label']) {
              isDetected = true;
              if (mounted) {
                setState(() {
                  label = element['label'];
                });
              }
            }
          } else {
            if (label != "") {
              isDetected = false;
              if (mounted)
                setState(() {
                  label = "";
                });
            }
          }
        }
      }
    } catch (e) {}
    // mainController.predictions(prediction);
  }

  @override
  void initState() {
    super.initState();
    getAvailableCamera();
    _streamSubscriptions.add(accelerometerEvents.listen((data) {
      // print(data);
      x = data.x.floor();
      y = data.y.floor();
      z = data.z.round();
      checkAngle(data);
    }, onError: (err) {}, onDone: () {}));
    setState(() {});
  }

  checkAngle(AccelerometerEvent data) {
    // print("""$x $y $z""");

    /// portrait case
    if (x == 0 && y == 9 && z == 0) {
      if (phone != "portrait") {
        setState(() {
          phone = "portrait";
        });
      }
      print("portrait");
      if (isCapturing) return;
    } else if (x == 0 && y == 0 && (z) > 9) {
      // print("protraint 1");
      if (phone != "portrait") {
        phone = "portrait";
        setState(() {});
      }
      // print("portrait");
      if (isCapturing) return;
    } else if (x == 0 && y == 7 && z == 0) {
      // print("45 degree detected");
      if (phone != "45 degree") {
        isCapturing = true;
        setState(() {
          phone = "45 degree";
        });
      }
      // print("portrait");
      if (isCapturing) return;
    } else if (x == 0 && y == 7 && z == 7) {
      // print("45 degree 1");
      if (phone != "45 degree") {
        isCapturing = true;
        setState(() {
          phone = "45 degree";
        });
      }
    } else {
      // if (label != "Failed detection") {
      setState(() {
        phone = "";
      });
      // }
      // print("Failed detection");
    }

    //      // Using x y and z from accelerometer, calculate x and y angles
    // double x_val, y_val, z_val, result;
    // double x2, y2, z2; //24 bitshort long

    // //  // Lets get the deviations from our baseline
    // var accel_center_x = 0;
    // var accel_center_y = 0;
    // var accel_center_z = 10;
    // var accel_value_x = data.x;
    // var accel_value_z = data.z;
    // var accel_value_y = data.y;
    // x_val = accel_value_x - accel_center_x;

    // var accel_angle_x, accel_angle_y;
    // y_val = accel_value_y - accel_center_y;
    // z_val = accel_value_z - accel_center_z;

    // //  // Work out the squares
    // x2 = (x_val * x_val);
    // y2 = (y_val * y_val);
    // z2 = (z_val * z_val);

    // //  //X Axis
    // result = sqrt(y2 + z2);
    // result = x_val / result;
    // accel_angle_x = atan(result);

    // //  //Y Axis
    // result = sqrt(x2 + z2);
    // result = y_val / result;
    // accel_angle_y = atan(result);
    // print(accel_angle_x);
    // print(accel_angle_y);
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  takePicture(cameraImage) async {
    var image = await convertYUV420toImageColor(cameraImage);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    // cameraController.stopImageStream();
    // print(appDocPath);
    var file = File(
        "${appDocPath + DateTime.now().millisecondsSinceEpoch.toString()}.png");
    await file.writeAsBytes(image);

    // var newImage = await cropImage(file.path);
    widget.type == "FrontCapture"
        ? controller.frontImage(file.path)
        : widget.type == "BackCapture"
            ? controller.backImage(file.path)
            : widget.type == "TiltedImage"
                ? controller.tilted(file.path)
                : controller.selfie(file.path);
    controller.nextPage();

    ///TODO:CAMERA TAKE PICTURE
    ///
    /// camera controller when stream disabled
    // await cameraController.takePicture().then((image) {
    //   if (widget.type == "FrontCapture") {
    //     controller.frontImage(image.path);
    //     controller.pageController
    //         .nextPage(duration: 200.milliseconds, curve: Curves.ease);
    //   } else if (widget.type == "BackCapture") {
    //     controller.backImage(image.path);
    //     controller.nextPage();
    //   } else if (widget.type == "TiltedImage") {
    //     controller.tilted(image.path);
    //     controller.nextPage();
    //   } else {
    //     _streamSubscriptions.map((e) {
    //       e.cancel();
    //     });
    //     setState(() {});

    //     controller.selfie(image.path);
    //     controller.pageController
    //         .nextPage(duration: 200.milliseconds, curve: Curves.ease);
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      // DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
      body: Stack(children: [
        if (isInitialized)
          Center(
            child: SizedBox(child: CameraPreview(cameraController)),
          ),
        Center(
          child: Container(
            height: 300,
            width: 350,
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
        Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(phone,
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
                ])),
            Text(
              label,
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
            )
          ],
        )),
        Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
                onTap: () {
                  if (isDetected ||
                      phone == 'portrait' &&
                          (widget.type == "FrontCapture" ||
                              widget.type == "BackCapture")) {
                    takePicture(image);
                  } else if (phone == "45 degree" &&
                      widget.type == "TiltedImage") {
                    takePicture(image);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          width: label != "" ? 2 : 1.5,
                          color: phone == 'portrait'
                              ? Colors.green
                              : label != ""
                                  ? Colors.green
                                  : Colors.grey)),
                  alignment: Alignment.center,
                  height: 50,
                  width: 150,
                  child: const Text(
                    "Capture",
                  ),
                )))
      ]),
    );
  }
}
