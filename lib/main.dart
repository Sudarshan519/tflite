import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:get/get.dart';
import 'package:tflite/tflite.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as imglib;
import 'captured_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CameraController? cameraController;
  final MainController mainController = Get.put(MainController());
  var cameras = [];
  File? image;
  var base64;
  var cameraImage;
  bool isVideoRecording = false;
  var output;
  bool showFocusCircle = false;

  double x = 0;

  double y = 0;
  GlobalKey imagePreview = new GlobalKey();
  getAvailableCamera() async {
    image = null;
    loadmodel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.max);
    cameraController!.initialize().then((_) {
      startImageStream();
      setState(() {});
    });
  }

  // TODO: ISOLATE TO RUN MODEL SEPARATELY
  runOnIsolate() {}

  // TODO: Model Improvisization
  // TODO: Scan from picture
  // TODO: capture Image from model scan
  // TODO: compare images

  captureImage() async {
    try {
      if (cameraController!.value.isTakingPicture) {
        // A capture is already pending, do nothing.
        return null;
      }

      XFile file = await cameraController!.takePicture();

      image = File(file.path);
      // print(file.path);
      // cameraController!.dispose();
      // cameraController = null;
      mainController.image(file.path);
      setState(() {});
      runmodelonImage();
      // runmodelonImage();
      //   convertToByte64();
    } catch (e) {
      print(e.toString());
    }
  }

  captureVideo() {
    if (cameraController!.value.isInitialized) {
      isVideoRecording = true;
    }
  }

  startRecording() {
    cameraController!.startVideoRecording().then((value) => {});
  }

  stopVideoRecording() {
    cameraController!.stopVideoRecording().then((value) => {});
  }

  startImageStream() async {
    var data;
    await cameraController!.startImageStream((image) {
      // setState(() {
      runModel(image);
      // compute(runModel, image);
      // });
    });
  }

  stopImageStream() async {
    await cameraController!.stopImageStream();
  }

  convertToByte64() {
    var bytes = File(image!.path).readAsBytesSync();
    base64 = base64Encode(bytes);
    setState(() {});
    print(base64);
  }

  validateImage() {
    if ("0 Front" == mainController.lagel.value) {}
  }

  Future<void> _focusCamera(TapUpDetails details) async {
    if (cameraController!.value.isInitialized) {
      showFocusCircle = true;
      x = details.localPosition.dx;
      y = details.localPosition.dy;

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * cameraController!.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp, yp);
      print("point : $point");

      // Manually focus
      try {
        await cameraController!.setFocusPoint(point);
        setState(() {
          Future.delayed(const Duration(seconds: 2)).whenComplete(() {
            setState(() {
              showFocusCircle = false;
            });
          });
        });
      } catch (e) {}
      // Manually set light exposure
      //controller.setExposurePoint(point);

    }
  }

  takeScreenShot() async {
    RenderRepaintBoundary? boundary = imagePreview.currentContext!
        .findRenderObject() as RenderRepaintBoundary?;
    ui.Image image = await boundary!.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    print(byteData);
  }

  void captureFromStream() async {
    var image = await convertYUV420toImageColor(cameraImage);
    cameraController!.dispose();
    cameraController = null;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CapturedImage(image: image)));
  }

  @override
  void initState() {
    super.initState();
    getAvailableCamera();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    cameraController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
              onPressed: () {
                getAvailableCamera();
              },
              child: const Text("Start")),
          ElevatedButton(
              onPressed: () {
                cameraController!.dispose();
                cameraController = null;
                setState(() {});
              },
              child: const Text("StopCamera"))
        ],
      ),
      body:

          //image not null
          image != null
              ? SingleChildScrollView(
                  // padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 80,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            GestureDetector(
                                onTapUp: (details) {
                                  mainController.image(image!.path);
                                  mainController.convertToByte64();
                                  // x = details.localPosition.dx;
                                  // y = details.localPosition.dy;
                                  // print(x);
                                  // print(y);

                                  // setState(() {});

                                  // double fullWidth =
                                  //     MediaQuery.of(context).size.width;
                                  // double cameraHeight = fullWidth * 16 / 9;

                                  // double xp = x / fullWidth;
                                  // double yp = y / cameraHeight;

                                  // Offset point = Offset(xp, yp);
                                },
                                child: Image.file(
                                  image!,
                                  height: MediaQuery.of(context).size.height,
                                  width: double.infinity,
                                  fit: BoxFit.fill,
                                )),
                            Center(
                              child: Positioned(
                                top: y - 20,
                                left: x - 20,
                                child: Container(
                                  height: 200,
                                  width: 300,
                                  decoration: BoxDecoration(
                                      // shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 1.5)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const Text("Base64 Image"),
                      Obx(() => Text(mainController.predictions.toString())),
                      Text(mainController.image.toString()),
                      Text(base64.toString()),
                      ElevatedButton(
                          onPressed: () {
                            takeScreenShot();
                          },
                          child: Text("Capture")),
                    ],
                  ),
                )
              :

              // image null
              //camera initialized
              cameraController != null
                  ? Stack(
                      children: [
                        GestureDetector(
                          onTapUp: (details) {
                            _focusCamera(details);
                          },
                          child: Container(
                            height: double.infinity,
                            color: Colors.black,
                            width: double.infinity,
                            child: AspectRatio(
                              aspectRatio: MediaQuery.of(context).size.height /
                                  MediaQuery.of(context).size.width,
                              child: CameraPreview(
                                cameraController!,
                              ),
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.flash_auto),
                                InkWell(
                                  onTap: () {
                                    // captureImage();
                                    //

                                    captureFromStream();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "Capture",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Obx(
                                  () => Container(
                                    color: Colors.black,
                                    child: Text(
                                      mainController.lagel.value.toString() +
                                          "with confidence ${mainController.confidence.value} %",
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),

                                // InkWell(
                                //   onTap: () {},
                                //   child: Container(
                                //       margin: const EdgeInsets.only(bottom: 20),
                                //       width: 40,
                                //       height: 40,
                                //       decoration: const BoxDecoration(
                                //           shape: BoxShape.circle,
                                //           color: Colors.white),
                                //       alignment: Alignment.center,
                                //       child:
                                //           const Icon(Icons.video_camera_back)),
                                // )
                              ],
                            )),
                        // if (showFocusCircle)
                        Center(
                          // child: Positioned(
                          // top: y - 20,
                          // left: x - 20,
                          child: Obx(
                            () => RepaintBoundary(
                              // key: imagePreview,
                              child: Container(
                                  height: 200,
                                  width: 300,
                                  decoration: BoxDecoration(
                                      // shape: BoxShape.circle,

                                      border: Border.all(
                                          color: mainController.lagel.value ==
                                                  "0 Front"
                                              ? Color.fromARGB(255, 23, 181, 33)
                                              : mainController.lagel.value ==
                                                      "1 Back"
                                                  ? Colors.blue
                                                  : mainController
                                                              .lagel.value ==
                                                          "2 Tilted"
                                                      ? Colors.red
                                                      : Colors.white,
                                          width: mainController.lagel.value ==
                                                  "0 Front"
                                              ? 3
                                              : 1.5))),
                            ),
                          ),
                        ),
                        Positioned(
                          top: y - 20,
                          left: x - 20,
                          child: RepaintBoundary(
                            key: imagePreview,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 1.5)),
                            ),
                          ),
                        ),
                        // )
                      ],
                    )
                  :
                  // camera initializing
                  const Center(child: Text("Camera Stopped")),
    );
  }

  //run model on image
  runmodelonImage() async {
    var prediction = await Tflite.runModelOnImage(
      path: image!.path,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 5,
      threshold: .1,
      asynch: true,
    );
    prediction!.forEach((element) {
      print(element['label']);
    });
    // mainController.predictions(prediction);
  }

  runModel(CameraImage image) async {
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

      //  sleep(Duration(seconds: 1));
      // setState(() {
      //   predictions!.last['label'];
      // });
      // return predictions;
      predictions!.forEach((element) {
        print(element['label'] + "prediction");
        print(element.toString());
        if (mainController.lagel.value != element['label']) {
          // && element['confidence'] > 70
          mainController.lagel(element['label']);
          mainController.confidence(element['confidence'].toString());
        } // else if (element['confidence'] > 70)
        else {
          mainController.predictions.add(element['label']);
          mainController.confidence(element['confidence'.toString()]);
        }
      });
      cameraImage = image;
    } catch (e) {
      return null;
    }
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }
}

class CapturedImage extends StatelessWidget {
  const CapturedImage({
    Key? key,
    required this.image,
  }) : super(key: key);

  final image;

  @override
  Widget build(BuildContext context) {
    // print(image.data.buffer.asInt8List());
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Transform.rotate(
          angle: (90 * 3.1415927 / 180),
          child: Image.memory(
            image,
          ),
        ),
      )),
    );
  }
}
