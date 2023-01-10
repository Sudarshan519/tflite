import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pkg/const/strings.dart';
import 'package:flutter_pkg/controller/main_controller.dart';
import 'package:get/get.dart';

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
    getBase64(widget.type == AppStrings.FRONT
        ? controller.frontImage.value
        : widget.type == AppStrings.BACK
            ? controller.backImage.value
            : widget.type == AppStrings.TILTED
                ? controller.tilted.value
                : controller.selfie.value);
    widget.type == AppStrings.FRONT
        ? controller.frontImageByte(base64)
        : widget.type == AppStrings.BACK
            ? controller.backImageByte(base64)
            : widget.type == AppStrings.TILTED
                ? controller.tiltedByte(base64)
                : controller.selfieByte(base64);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 18.0, right: 18.0),
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
                widget.type == AppStrings.FRONT
                    ? controller.frontImage.value
                    : widget.type == AppStrings.BACK
                        ? controller.backImage.value
                        : widget.type == AppStrings.TILTED
                            ? controller.tilted.value
                            : controller.selfie.value,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(20.0),
            //   child: Text(base64.substring(0, 200)),
            // ),
            const SizedBox(
              height: 20,
            ),

            Image.asset(widget.type == AppStrings.SELFIE
                ? "assets/images/fail_pattern.webp"
                : widget.type == AppStrings.TILTED
                    ? "assets/images/drive_license_fail_pattern_diagonal.webp"
                    : "assets/images/drive_license_fail_pattern.webp"),

            const SizedBox(
              height: 20,
            ),
            // Text(
            //   "Decoded Image",
            //   style: Theme.of(context).textTheme.bodyLarge,
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Image.memory(
            //   base64Decode(base64),
            //   height: 300,
            //   width: 320,
            //   fit: BoxFit.fitWidth,
            // ),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () {
                          controller.pageController.previousPage(
                              duration: 300.milliseconds, curve: Curves.ease);
                        },
                        child: const Text(AppStrings.RETAKE))),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ElevatedButton(
                      style: OutlinedButton.styleFrom(),
                      onPressed: () {
                        controller.pageController.nextPage(
                            duration: 300.milliseconds, curve: Curves.ease);
                      },
                      child: const Text(AppStrings.NEXT)),
                )
              ],
            )
          ],
        ),
      ),
    ));
  }
}
