import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  var blinks = 0.obs;

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
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    pageController = null;
    super.onClose();
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
