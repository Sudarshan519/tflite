library flutter_pkg;

import 'package:flutter/material.dart';
import 'package:flutter_pkg/const/strings.dart';
import 'package:flutter_pkg/controller/main_controller.dart';
import 'package:flutter_pkg/screens/capture.dart';
import 'package:flutter_pkg/screens/confirmation.dart';
import 'package:flutter_pkg/screens/face_detectionMLKit.dart';
import 'package:flutter_pkg/screens/final_confirmation.dart';
import 'package:flutter_pkg/screens/intro_screen.dart';
import 'package:flutter_pkg/screens/liveliness.dart';
import 'package:flutter_pkg/screens/tutorial.dart';
import 'package:get/get.dart';

class DocumentVerification extends StatefulWidget {
  const DocumentVerification({
    Key? key,
  }) : super(key: key);

  @override
  State<DocumentVerification> createState() => _DocumentVerificationState();
}

class _DocumentVerificationState extends State<DocumentVerification> {
  final MainController mainController = Get.put(MainController());
  final pages = [
    const IntroScreen(),
    const IntroSecond(),
    const Tutorial(title: AppStrings.FRONT),
    const CaptureImage(type: AppStrings.FRONT),
    const Confirmation(type: AppStrings.FRONT),
    const Tutorial(title: AppStrings.TILTED),
    const CaptureImage(type: AppStrings.TILTED),
    const Confirmation(type: AppStrings.TILTED),
    const Tutorial(title: AppStrings.BACK),
    const CaptureImage(type: AppStrings.BACK),
    const Confirmation(type: AppStrings.BACK),
    const FaceDetectionMlKit(),
    const Confirmation(type: AppStrings.SELFIE),
    const LivelinessMlKit(),
    const DocumentConfirmation()
  ];

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        physics: const NeverScrollableScrollPhysics(),
        controller: mainController.pageController,
        itemCount: pages.length,
        itemBuilder: (_, i) => pages[i]);
  }
}
