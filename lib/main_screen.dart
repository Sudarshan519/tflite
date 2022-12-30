import 'dart:io';
import 'dart:convert';
import 'package:flutter_face_verification/screens/face_detection_screen.dart';
import 'package:flutter_face_verification/screens/liveliness_detection_screen.dart';
import 'package:get/get.dart';
import 'screens/capture_screen.dart';
import 'package:flutter/material.dart';
import 'screens/introductions_screen.dart';
import 'package:flutter_face_verification/controller.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);
  final MainController mainController = Get.isRegistered<MainController>()
      ? Get.find()
      : Get.put(MainController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Main Screen")),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const FlutterLogo(
            size: 100,
          ),
          const SizedBox(height: 20),
          Text("Start Document Verification Process",
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const DocuemntProcessScreen());
                    },
                    child: const Text("Start"))),
          )
        ],
      ),
    );
  }
}

class DocuemntProcessScreen extends StatefulWidget {
  const DocuemntProcessScreen({Key? key}) : super(key: key);

  @override
  State<DocuemntProcessScreen> createState() => _DocuemntProcessScreenState();
}

class _DocuemntProcessScreenState extends State<DocuemntProcessScreen> {
  @override
  void initState() {
    super.initState();
  }

  final MainController controller = Get.isRegistered<MainController>()
      ? Get.find()
      : Get.put(MainController());
  List<Widget> pages = [
    const LivelinessDetection(),
    const IntroScreen(),
    const IntroSecond(),
    const Tutorial(title: "FrontTutorial"),
    const CaptureImage(type: "FrontCapture"),
    const Confirmation(type: "FrontCapture"),
    const Tutorial(title: "BackTutorial"),
    const CaptureImage(type: "BackCapture"),
    const Confirmation(type: "BackCapture"),
    const Tutorial(title: "TiltedTutorial"),
    const CaptureImage(type: "TiltedImage"),
    const Confirmation(type: "TiltedCapture"),
    const Tutorial(title: "SelfieTutorial"),
    const FaceDetection(),
    const Confirmation(type: "SelfieCapture"),
    const Tutorial(title: "Liveliness Tutorial"),
    const LivelinessDetection(),
    const DocumentConfirmation()
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: PageView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller.pageController,
              itemCount: pages.length,
              itemBuilder: ((context, index) => pages[index])),
        ),
      ],
    );
  }
}

class IntroSecond extends StatelessWidget {
  const IntroSecond({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                child: Text(
                  "Align your identity verification document with the specified position\n.",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Image.asset(
                "assets/images/drive_license_random.gif",
              ),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: Get.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(0, 149, 235, 1)),
                      onPressed: () {
                        controller.pageController.nextPage(
                            duration: 300.milliseconds, curve: Curves.ease);
                      },
                      child: const Text("Start Tutorial")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Tutorial extends StatefulWidget {
  const Tutorial({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 80,
                top: 200,
                child: Container(
                  color: Colors.black,
                  child: Image.asset(
                    "assets/images/drive_license_front_shooting.gif",
                    width: 400,
                    height: 250,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 50.0, horizontal: 8),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                      width: Get.width,
                      child: ElevatedButton(
                          onPressed: () {
                            controller.pageController.nextPage(
                                duration: 300.milliseconds, curve: Curves.ease);
                          },
                          child: const Text("Start Capture"))),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ));
  }
}

class Confirmation extends StatefulWidget {
  const Confirmation({Key? key, required this.type}) : super(key: key);
  final String type;
  @override
  State<Confirmation> createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  final MainController controller = Get.find();
  var base64 = "";
  getBase64(path) {
    base64 = convertToByte64(path);
  }

  @override
  void initState() {
    super.initState();
    getBase64(widget.type == "FrontCapture"
        ? controller.frontImage.value
        : widget.type == "BackCapture"
            ? controller.backImage.value
            : widget.type == "TiltedCapture"
                ? controller.tilted.value
                : controller.selfie.value);
    widget.type == "FrontCapture"
        ? controller.frontImageByte(base64)
        : widget.type == "BackCapture"
            ? controller.backImageByte(base64)
            : widget.type == "TiltedCapture"
                ? controller.tiltedByte(base64)
                : controller.selfieByte(base64);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              "Confirmation",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            Image.file(
              File(
                widget.type == "FrontCapture"
                    ? controller.frontImage.value
                    : widget.type == "BackCapture"
                        ? controller.backImage.value
                        : widget.type == "TiltedCapture"
                            ? controller.tilted.value
                            : controller.selfie.value,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(base64.substring(0, 200)),
            ),
            Text(
              "Decoded Image",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 10,
            ),
            Image.memory(
              base64Decode(base64),
              height: 300,
              width: 320,
              fit: BoxFit.fitWidth,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Row(
                children: [
                  OutlinedButton(
                      onPressed: () {
                        controller.pageController.previousPage(
                            duration: 300.milliseconds, curve: Curves.ease);
                      },
                      child: const Text("Retake")),
                  OutlinedButton(
                      onPressed: () {
                        // pagecontroller.previousPage(
                        //     duration: 300.milliseconds, curve: Curves.ease);
                        controller.pageController.nextPage(
                            duration: 300.milliseconds, curve: Curves.ease);
                      },
                      child: Text("Next"))
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}

class DocumentConfirmation extends StatefulWidget {
  const DocumentConfirmation({Key? key}) : super(key: key);

  @override
  State<DocumentConfirmation> createState() => _DocumentConfirmationState();
}

class _DocumentConfirmationState extends State<DocumentConfirmation> {
  MainController controller = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Obx(
            () => Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Front Image",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Image.file(
                  File(controller.frontImage.value),
                  height: 300,
                  width: 320,
                  fit: BoxFit.cover,
                ),
                Text(controller.frontImageByte.value.substring(0, 100)),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Back Image",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(controller.backImageByte.value.substring(0, 100)),
                Image.file(
                  File(controller.backImage.value),
                  height: 300,
                  width: 320,
                  fit: BoxFit.cover,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Tilted Image",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Image.file(
                  File(controller.tilted.value),
                  height: 300,
                  width: 320,
                  fit: BoxFit.cover,
                ),
                Text(controller.tiltedByte.value.substring(0, 100)),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Selfie Image",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Image.file(
                  File(controller.selfie.value),
                  height: 300,
                  width: 320,
                  fit: BoxFit.cover,
                ),
                Text(controller.selfieByte.value.substring(0, 100)),
                ElevatedButton(
                    onPressed: () async {
                      PageController pagecontroller = controller.pageController;
                      pagecontroller.previousPage(
                          duration: 300.milliseconds, curve: Curves.ease);
                      pagecontroller.previousPage(
                          duration: 300.milliseconds, curve: Curves.ease);
                      // await Get.delete<MainController>();

                      // Get.offAll(() => MainScreen());
                    },
                    child: const Text("Submit"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
