import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:get/get.dart';

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
  getAvailableCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(
        widget.type == "SelfieCapture" ? cameras[1] : cameras[0],
        ResolutionPreset.medium);
    cameraController.initialize().then((_) {
      isInitialized = true;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    getAvailableCamera();
    _streamSubscriptions.add(accelerometerEvents.listen((data) {
      print(data);
      x = data.x.floor().abs();
      y = data.y.floor().abs();
      z = data.z.floor().abs();
      checkAngle();
    }, onError: (err) {}, onDone: () {}));
    setState(() {});
  }

  checkAngle() {
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

  takePicture() async {
    await cameraController.takePicture().then((image) {
      if (widget.type == "FrontCapture") {
        controller.frontImage(image.path);
        controller.pageController
            .nextPage(duration: 200.milliseconds, curve: Curves.ease);
      } else if (widget.type == "BackCapture") {
        controller.backImage(image.path);
        controller.nextPage();
      } else if (widget.type == "TiltedImage") {
        controller.tilted(image.path);
        controller.nextPage();
      } else {
        _streamSubscriptions.map((e) {
          e.cancel();
        });
        setState(() {});

        controller.selfie(image.path);
        controller.pageController
            .nextPage(duration: 200.milliseconds, curve: Curves.ease);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        if (isInitialized)
          Center(
            child: SizedBox(
                height: 300,
                width: 340,
                child: CameraPreview(cameraController)),
          ),
        Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
                onTap: () {
                  takePicture();
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey)),
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
