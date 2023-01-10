import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pkg/controller/main_controller.dart';
import 'package:get/get.dart';

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
            () => Center(
              child: Column(
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
                    height: 200,
                    width: 320,
                    fit: BoxFit.fill,
                  ),
                  // Text(controller.frontImageByte.value.substring(0, 100)),
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
                  // Text(controller.backImageByte.value.substring(0, 100)),
                  Image.file(
                    File(controller.backImage.value),
                    height: 200,
                    width: 320,
                    fit: BoxFit.fill,
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
                    height: 200,
                    width: 320,
                    fit: BoxFit.fill,
                  ),
                  // Text(controller.tiltedByte.value.substring(0, 100)),
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
                    width: 320,
                    fit: BoxFit.cover,
                  ),
                  // Text(controller.selfieByte.value.substring(0, 100)),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop({
                          "front": controller.frontImageByte.value,
                          "tilted": controller.tiltedByte.value,
                          "back": controller.backImageByte.value,
                          "liveliness": true,
                          "selfie": controller.selfie.value,
                        });
                        // PageController pagecontroller =
                        //     controller.pageController;
                        // pagecontroller.previousPage(
                        //     duration: 300.milliseconds, curve: Curves.ease);
                        // pagecontroller.previousPage(
                        //     duration: 300.milliseconds, curve: Curves.ease);
                      },
                      child: const Text("Submit"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
