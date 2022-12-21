import 'dart:convert';
import 'dart:io'; 
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_face_verification/controller.dart';
import 'package:flutter_face_verification/main_screen.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';
import 'dart:ui' as ui;
import 'captured_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
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
  final MainController mainController = Get.find<MainController>();
  var cameras = [];
  File? image;
  var base64;
  var cameraImage;
  bool isVideoRecording = false;
  var output;
  bool showFocusCircle = false;

  double x = 0;

  double y = 0;
  GlobalKey imagePreview = GlobalKey();
  getAvailableCamera() async {
    image = null;
    loadmodel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.max);
    cameraController!.initialize().then((_) {
      // startImageStream();
      setState(() {});
    });
  }

  // TODO: compare images

  captureImage() async {
    try {
      if (cameraController!.value.isTakingPicture) {
        // A capture is already pending, do nothing.
        return null;
      }

      await cameraController!.takePicture().then((file) {
        if (widget.title == 'FrontCapture') {
          mainController.frontImage(file.path);
          mainController.nextPage();
        }
      });

      // mainController.pageController
      //     .nextPage(duration: 300.milliseconds, curve: Curves.ease);
      // }

      // switch (widget.title) {
      //   case "FrontCapture":
      // mainController.frontImage(file.path);
      // mainController.pageController
      //     .nextPage(duration: 300.milliseconds, curve: Curves.ease);
      //     break;
      //   default:
      //     print(widget.title);
      // }
      // cameraController!.dispose();
      // cameraController = null;
      // mainController.image(file.path);

      // runmodelonImage();

      // runmodelonImage();
      // var base64 = convertToByte64();
      // mainController.frontCapturedImage(base64);
      // mainController.frontImage(image);
      // if (widget.title == "FrontCapture") {
      //   mainController.frontImage(image);
      // mainController.pageController
      //     .nextPage(duration: 300.milliseconds, curve: Curves.ease);
      // }
      // switch (widget.title) {
      //   case 'FrontCapture':
      // mainController.frontImage(image);
      // mainController.pageController
      //     .nextPage(duration: 300.milliseconds, curve: Curves.ease);
      //     break;
      //   case 'BackCapture':
      //     mainController.backImage(image);
      //     mainController.pageController
      //         .nextPage(duration: 300.milliseconds, curve: Curves.ease);
      //     break;
      //   case 'TiltedCapture':
      //     mainController.tilted(image);
      //     mainController.pageController
      //         .nextPage(duration: 300.milliseconds, curve: Curves.ease);
      //     break;
      //   case 'SelfieCapture':
      //     mainController.selfie(image);
      //     mainController.pageController
      //         .nextPage(duration: 300.milliseconds, curve: Curves.ease);
      //     break;
      //   default:
      //     mainController.frontImage(image);
      //     mainController.pageController
      //         .nextPage(duration: 300.milliseconds, curve: Curves.ease);
      // }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
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
      cameraImage = image;
      // setState(() {
      // runModel(image);
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
    return base64;
    // setState(() {});
    // print(base64);
  }

  validateImage() {
    if ("0 Front" == mainController.lagel.value) {}
  }

  Future<void> _focusCamera(TapUpDetails details) async {
    if (cameraController!.value.isInitialized) {
      // showFocusCircle = true;
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
    Get.to(Scaffold(
      body: Image.memory(byteData!.buffer.asUint8List()),
    ));
  }

  void captureFromStream() async {
    var image = await convertYUV420toImageColor(cameraImage);
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    // print(appDocPath);
    var file = File(
        "${appDocPath + DateTime.now().millisecondsSinceEpoch.toString()}.png");
    await file.writeAsBytes(image);
    // print(file.path);
    // print(widget.title);
    mainController.pageController
        .nextPage(duration: 300.milliseconds, curve: Curves.ease);
    if (widget.title == 'FrontCapture') {
      mainController.frontImage(file.path);
      mainController.nextPage();
      // Get.to(ImageWidget(file: file));
    }

    // Get.to(ImageWidget(file: file));
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (_) => CapturedImage(image: image)));
    // image = file.path;
    // print(image);
    // cameraController!.dispose();
    // cameraController = null;
    // switch (widget.title) {
    //   case 'FrontCapture':
    //     mainController.frontImage(image);
    //     Get.to(ImageWidget(file: file));
    //     break;
    //   case 'BackCapture':
    //     mainController.backImage(image);
    //     break;
    //   case 'TiltedCapture':
    //     mainController.tilted(image);
    //     break;
    //   case 'SelfieCapture':
    //     mainController.selfie(image);
    //     break;
    //   default:
    //     mainController.frontImage(image);
    //     break;
    // }
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
    cameraController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        title: Text(widget.title),
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
                                  // mainController.convertToByte64();
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
                              // child: Positioned(
                              //   top: y - 20,
                              //   left: x - 20,
                              child: Container(
                                height: 200,
                                width: 340,
                                decoration: BoxDecoration(
                                    // shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1.5)),
                                // ),
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
                            // takeScreenShot();
                          },
                          child: const Text("Capture")),
                    ],
                  ),
                )
              :

              // image null
              //camera initialized
              cameraController != null
                  ? RepaintBoundary(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTapUp: (details) {
                              // _focusCamera(details);
                            },
                            child: Container(
                              height: double.infinity,
                              color: Colors.black,
                              width: double.infinity,
                              child: AspectRatio(
                                aspectRatio:
                                    MediaQuery.of(context).size.height /
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
                                  // const Spacer(),
                                  const Expanded(child: Icon(Icons.flash_auto)),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        captureImage();

                                        // takeScreenShot();
                                        // captureImage();
                                        // captureFromStream();
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 20),
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
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Obx(
                                    () => Expanded(
                                      child: Container(
                                        color: Colors.black,
                                        child: Text(
                                          mainController.lagel.value
                                                  .toString() +
                                              "with confidence ${mainController.confidence.value} %",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
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
                          // Center(
                          //   child: Positioned(
                          //     top: y - 20,
                          //     left: x - 20,
                          //     child: Obx(() => RepaintBoundary(
                          //           // key: imagePreview,
                          //           child: Container(
                          //               height: 200,
                          //               width: 360,
                          //               decoration: BoxDecoration(
                          //                   // shape: BoxShape.circle,

                          //                   border: Border.all(
                          //                       color: mainController
                          //                                   .lagel.value ==
                          //                               "0 Front"
                          //                           ? const Color.fromARGB(
                          //                               255, 23, 181, 33)
                          //                           : mainController
                          //                                       .lagel.value ==
                          //                                   "1 Back"
                          //                               ? Colors.blue
                          //                               : mainController.lagel
                          //                                           .value ==
                          //                                       "2 Tilted"
                          //                                   ? Colors.red
                          //                                   : Colors.white,
                          //                       width: mainController
                          //                                   .lagel.value ==
                          //                               "0 Front"
                          //                           ? 3
                          //                           : 1.5))),
                          //         )),
                          //   ),
                          // ),

                          // if (showFocusCircle)
                          //   Positioned(
                          //     top: y - 20,
                          //     left: x - 20,
                          //     child: Container(
                          //       height: 40,
                          //       width: 40,
                          //       decoration: BoxDecoration(
                          //           shape: BoxShape.circle,
                          //           border: Border.all(
                          //               color: Colors.white, width: 1.5)),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    )
                  :
                  // camera initializing
                  // const Center(child: Text("Camera Stopped")),

                  Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: OutlinedButton(
                            onPressed: () {
                              mainController.pageController.nextPage(
                                  duration: 200.milliseconds,
                                  curve: Curves.ease);
                            },
                            child: const Text("Start Process"),
                          ),
                        )
                      ],
                    ),
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
      print(element);
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

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    Key? key,
    required this.file,
  }) : super(key: key);

  final File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Image.file(
          file,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}

class CapturedImage extends StatelessWidget {
  const CapturedImage({
    Key? key,
    required this.image,
  }) : super(key: key);

  final Uint8List image;
  // getDecodedImage(Uint8List image) async {
  //   final buffer = await ui.ImmutableBuffer.fromUint8List(image);
  //   final descriptor = await ui.ImageDescriptor.encoded(buffer);
  //   print(descriptor.height);
  //   print(descriptor.width);
  // }

  @override
  Widget build(BuildContext context) {
    // print(image.data.buffer.asInt8List());
    // getDecodedImage(image);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Stack(
                children: [
                  // Transform.translate(
                  //   offset: Offset(-90, -100),
                  //   child: Transform.rotate(
                  //     angle: -math.pi / ,
                  //     child: Image.memory(image),
                  //   ),
                  // ),
                  Transform.rotate(
                    angle: (90 * 3.1415927 / 180),
                    child: Image.memory(
                      image,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 100,
                    width: 200,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.grey)),
                  )
                ],
              ))),
    );
  }
}
