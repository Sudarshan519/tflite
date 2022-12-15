import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';

class MainController extends GetxController {
  var lagel = "INITIALIZING".obs;
  var base64Image = "".obs;
  var predictions = [].obs;
  var imagebytes = "".obs;
  var successLabel = false.obs;
  var confidence = "".obs;
  var image = "".obs;
  @override
  void onInit() {
    super.onInit();
  }

  convertToByte64() {
    var bytes = File(image.value).readAsBytesSync();
    base64Image(base64Encode(bytes));
    print(base64);
  }
}
