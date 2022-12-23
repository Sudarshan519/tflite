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
    const IntroScreen(),
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

class Tutorial extends StatefulWidget {
  const Tutorial({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  final MainController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: Get.width,
                    child: ElevatedButton(
                        onPressed: () {
                          controller.pageController.nextPage(
                              duration: 300.milliseconds, curve: Curves.ease);
                        },
                        child: const Text("Start Capture"))))
          ],
        ),
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
              height: 300,
              width: 320,
              fit: BoxFit.fitWidth,
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
                        controller.pageController.nextPage(
                            duration: 300.milliseconds, curve: Curves.ease);
                      },
                      child: const Text("Submit"))
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
                      await Get.delete<MainController>();

                      Get.offAll(() => MainScreen());
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
