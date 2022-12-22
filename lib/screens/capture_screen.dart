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

  getAvailableCamera() async {
    loadmodel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(
        widget.type == "SelfieCapture" ? cameras[1] : cameras[0],
        ResolutionPreset.max);
    cameraController.initialize().then((_) {
      isInitialized = true;
      modelReady = true;
      cameraController.startImageStream(runModelOnAvailableImage);

      setState(() {});
    });
  }

  runModelOnAvailableImage(cameraImage) {
    image = cameraImage;
    if (isRunning) {
      return;
    } else {
      // if (modelReady)

      runmodelonImage(cameraImage);
    }
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
    modelReady = true;
    setState(() {});
  }

  //run model on image
  runmodelonImage(CameraImage image) async {
    setState(() {
      isRunning = true;
    });
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

    setState(() {
      isRunning = false;
    });
    for (var element in predictions ?? []) {
      if (element['confidence'] > .70) {
        if (widget.type == "FrontCapture" && element['label'] == "0 Front") {
          if (label != element['label']) {
            isDetected = true;
            setState(() {
              label = element['label'];
            });
          }
        } else if (widget.type == "BackCapture" &&
            element['label'] == "1 Back") {
          if (label != element['label']) {
            isDetected = true;
            setState(() {
              label = element['label'];
            });
          }
        } else if (widget.type == "TiltedImage" &&
            element['label'] == "2 Tilted") {
          if (label != element['label']) {
            isDetected = true;
            setState(() {
              label = element['label'];
            });
          }
        } else {
          if (label != "") {
            isDetected = false;
            setState(() {
              label = "";
            });
          }
        }
        print(element);
      }
    }
    // mainController.predictions(prediction);
  }

  @override
  void initState() {
    super.initState();
    getAvailableCamera();
    _streamSubscriptions.add(accelerometerEvents.listen((data) {
      // print(data);
      x = data.x.round().abs();
      y = data.y.round().abs();
      z = data.z.round().abs();
      checkAngle();
    }, onError: (err) {}, onDone: () {}));
    setState(() {});
  }

  checkAngle() {
    // print("""$x $y $z""");

    /// portrait case
    if (x == 0 && y == 10 && z == 0) {
      if (label != "portrait") {
        setState(() {
          phone = "portrait";
        });
      }
      print("portrait");
      if (isCapturing) return;
    } else if (x == 0 && y == 0 && z == 10) {
      print("protraint 1");
      if (label != "portrait") {
        phone = "portrait";
        setState(() {});
      }
      // print("portrait");
      if (isCapturing) return;
    } else if (x == 0 && y == 7 && z == 0) {
      print("45 degree detected");
      if (label != "45 degree") {
        isCapturing = true;
        setState(() {
          phone = "45 degree";
        });
      }
      // print("portrait");
      if (isCapturing) return;
    } else if (x == 0 && y == 7 && z == 7) {
      print("45 degree 1");
      if (label != "45 degree") {
        isCapturing = true;
        setState(() {
          phone = "45 degree";
        });
      }
    } else {
      // if (label != "Failed detection") {
      setState(() {
        phone = "Failed detection";
      });
      // }
      // print("Failed detection");
    }

    //      // Using x y and z from accelerometer, calculate x and y angles
    //  float x_val, y_val, z_val, result;
    //  unsigned short long x2, y2, z2; //24 bit

    //  // Lets get the deviations from our baseline
    //  x_val = (float)accel_value_x-(float)accel_center_x;
    //  y_val = (float)accel_value_y-(float)accel_center_y;
    //  z_val = (float)accel_value_z-(float)accel_center_z;

    //  // Work out the squares
    //  x2 = (unsigned short long)(x_val*x_val);
    //  y2 = (unsigned short long)(y_val*y_val);
    //  z2 = (unsigned short long)(z_val*z_val);

    //  //X Axis
    //  result=sqrt(y2+z2);
    //  result=x_val/result;
    //  accel_angle_x = atan(result);

    //  //Y Axis
    //  result=sqrt(x2+z2);
    //  result=y_val/result;
    //  accel_angle_y = atan(result);
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
    // print(appDocPath);
    var file = File(
        "${appDocPath + DateTime.now().millisecondsSinceEpoch.toString()}.png");
    await file.writeAsBytes(image);
    widget.type == "FrontCapture"
        ? controller.frontImage(file.path)
        : widget.type == "BackCapture"
            ? controller.backImage(file.path)
            : widget.type == "TiltedImage"
                ? controller.tilted(file.path)
                : controller.selfie(file.path);
    controller.nextPage();

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
            child: SizedBox(
                // height: 300,
                // width: 340,
                child: CameraPreview(cameraController)),
          ),
        Transform(
          transform: Matrix4.identity()..rotateZ(0.0),
          child: Center(
            child: Container(
              height: 340,
              width: 500,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                      width: label != "" ? 2 : 1.5,
                      color: label != "" ? Colors.green : Colors.grey)),
            ),
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
                  if (isDetected) {
                    takePicture(image);
                  } else if (phone == "45 degree") {
                    takePicture(image);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          width: label != "" ? 2 : 1.5,
                          color: label != "" ? Colors.green : Colors.grey)),
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
