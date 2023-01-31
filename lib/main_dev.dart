import 'package:flutter/material.dart';
import 'package:flutter_face_verification/const/strings.dart';
import 'package:flutter_face_verification/main_screen.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.DOCUMENT_VERIFICATION,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}
