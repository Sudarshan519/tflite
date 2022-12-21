import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum STATE {
  MAIN,
  INTRO_SCREEN,
  DOCUMENT_FRONT_TUTORIAL,
  DOCUMENT_FRONT_CAPTURE,
  DOCUMENT_BACK_TUTORIAL,
  DOCUEMNT_BACK_CAPTURE,
  TITLED_CAPTURE_TUTORIAL,
  TILTED_CAPTURE_SCREEN,
  SELFIE_CAPTURE_TUTORIAL,
  SELFIE_CAPTURE_SCREEN,
  LIVELINESS_DETECTION_TUTORIAL
}
List states = [
  "MAIN",
  "INTRO_SCREEN",
  "DOCUMENT_FRONT_TUTORIAL",
  "DOCUMENT_FRONT_CAPTURE",
  "DOCUMENT_BACK_TUTORIAL",
  "DOCUEMNT_BACK_CAPTURE",
  "TITLED_CAPTURE_TUTORIAL",
  "TILTED_CAPTURE_SCREEN",
  "SELFIE_CAPTURE_TUTORIAL",
  "SELFIE_CAPTURE_SCREEN",
  "LIVELINESS_DETECTION_TUTORIAL"
];

class MainController extends GetxController {
  var lagel = "INITIALIZING".obs;

  var base64Image = "".obs;
  var predictions = [].obs;
  var imagebytes = "".obs;
  var successLabel = false.obs;
  var confidence = "".obs;
  var image = "".obs;
  var currentPage = 0.obs;
  var pageController;

  ///images
  var frontImage = "".obs;
  var backImage = "".obs;
  var tilted = "".obs;
  var selfie = "".obs;
  var frontImageByte = "".obs;
  var backImageByte = "".obs;
  var tiltedByte = "".obs;
  var selfieByte = "".obs;

  @override
  void onInit() {
    super.onInit();
    pageController = new PageController();
  }

  @override
  void onClose() {
    super.onClose();
    pageController.dispose();
  }

  nextPage() {
    pageController.nextPage(duration: 200.milliseconds, curve: Curves.ease);
  }

  convertImage() {
    frontImageByte(convertToByte64(frontImage.value));
    backImageByte(convertToByte64(backImage.value));
    tiltedByte(convertToByte64(tilted.value));
    selfieByte(convertToByte64(selfie.value));
  }
}

convertToByte64(image) {
  var bytes = File(image).readAsBytesSync();
  var base64 = base64Encode(bytes);
  return base64;
}
