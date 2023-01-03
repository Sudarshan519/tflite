import 'package:flutter_face_verification/const/strings.dart';
import 'package:flutter_face_verification/screens/document_process_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_face_verification/controller.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key? key}) : super(key: key);
  final MainController mainController = Get.isRegistered<MainController>()
      ? Get.find()
      : Get.put(MainController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.DOCUMENT_VERIFICATION)),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Center(
            child: FlutterLogo(
              size: 100,
            ),
          ),
          const SizedBox(height: 20),
          Text(AppStrings.DOCUMENT_VERIFICATION,
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
                    child: const Text(AppStrings.BEGIN_PROCESS))),
          )
        ],
      ),
    );
  }
}
