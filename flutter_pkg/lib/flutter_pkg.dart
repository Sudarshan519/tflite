library flutter_pkg;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_pkg/const/strings.dart';
import 'package:flutter_pkg/controller/main_controller.dart';
import 'package:flutter_pkg/screens/intro_screen.dart';
import 'package:flutter_pkg/screens/tutorial.dart';
import 'package:get/get.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class DocumentVerification extends StatefulWidget {
  const DocumentVerification({
    Key? key,
    required this.onFontDocumentFetched,
  }) : super(key: key);
  final Null Function(dynamic img) onFontDocumentFetched;

  @override
  State<DocumentVerification> createState() => _DocumentVerificationState();
}

class _DocumentVerificationState extends State<DocumentVerification> {
  final MainController mainController = Get.put(MainController());
  var pages = [IntroScreen(), IntroSecond(), Tutorial(title: AppStrings.FRONT)];
  var cameras = [];
  late CameraController cameraController;
  late PageController pageController;
  bool cameraInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: mainController.pageController,
        itemCount: 6,
        itemBuilder: (_, i) => pages[i]);
  }

  void initCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await cameraController.initialize();
    cameraInitialized = true;
    pageController = PageController(initialPage: 0);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }
}
