import 'package:flutter/material.dart';
import 'package:flutter_pkg/const/strings.dart';
import 'package:flutter_pkg/controller/main_controller.dart';
import 'package:get/get.dart';

class Tutorial extends StatefulWidget {
  const Tutorial({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  var loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();
    return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: widget.title == AppStrings.TILTED ? 0 : 80,
                top: 200,
                child: Container(
                  color: Colors.black,
                  child: loading
                      ? Image.asset(
                          widget.title == AppStrings.FRONT
                              ? "assets/images/drive_license_front_shooting.gif"
                              : widget.title == AppStrings.BACK
                                  ? "assets/images/drive_license_back_shooting.gif"
                                  : "assets/images/drive_license_diagonal_shooting.gif",
                          width: 400,
                          height: 250,
                          gaplessPlayback: true,
                        )
                      : const SizedBox(),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 50.0, horizontal: 8),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                      width: Get.width,
                      child: ElevatedButton(
                          onPressed: () {
                            controller.pageController.nextPage(
                                duration: 300.milliseconds, curve: Curves.ease);
                          },
                          child: const Text("Start Capture"))),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ));
  }
}
