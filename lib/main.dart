import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

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
  var cameras = [];
  File? image;
  var base64;
  bool isVideoRecording = false;
  var output;
  getAvailableCamera() async {
    image = null;
    loadmodel();
    List<CameraDescription> cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController!.initialize().then((_) {
      startImageStream();
      setState(() {});
    });
  }

  captureImage() async {
    // try {
    //   XFile file = await cameraController!.takePicture();

    //   image = File(file.path);
    //   // print(image!.path);
    //   cameraController!.dispose();
    //   // setState(() {});
    //   convertToByte64();
    // } catch (e) {}
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
    await cameraController!.startImageStream((image) {
      setState(() {
        runModel(image);
      });
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
              child: const Text("Retake"))
        ],
      ),
      body:

          //image not null
          image != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      Image.file(image!),
                      const Text("Base64 Image"),
                      Text(base64.toString())
                    ],
                  ),
                )
              :

              // image null
              //camera initialized
              cameraController != null
                  ? Stack(
                      children: [
                        Container(
                          height: double.infinity,
                          color: Colors.black,
                          width: double.infinity,
                          child: CameraPreview(
                            cameraController!,
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    captureImage();
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
                                Text(
                                  output.toString(),
                                  style: TextStyle(color: Colors.white),
                                )
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
                      ],
                    )
                  :
                  // camera initializing
                  const Center(child: Text("Initializing Camera")),
    );
  }

  void runModel(CameraImage image) async {
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
    predictions!.forEach((element) {
      print(element['label']);
      setState(() {
        output = element['label'];
      });
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }
}
