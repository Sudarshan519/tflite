import 'package:flutter/material.dart';
import 'package:flutter_pkg/controller/main_controller.dart';
import 'package:get/get.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final MainController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(12),
                decoration:
                    const BoxDecoration(color: Color.fromRGBO(84, 182, 234, 1)),
                child: Text(
                  "Three types of identity verification documents will be taken.",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(
                      child: Text(
                    "Surface",
                    textAlign: TextAlign.center,
                  )),
                  Expanded(
                      child: Image.asset(
                          "assets/images/drive_license_front.webp")),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Expanded(
                      child: Text(
                    "Oblique (45 degrees)",
                    textAlign: TextAlign.center,
                  )),
                  Expanded(
                    child: Image.asset(
                        "assets/images/drive_license_diagonal.webp"),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 18),
                child: Text(
                  "* Photographed from an angle to capture the thickness of the document.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const Divider(),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Expanded(
                      child: Text(
                    "Back",
                    textAlign: TextAlign.center,
                  )),
                  Expanded(
                    child: Image.asset("assets/images/drive_license_back.webp"),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Divider(),
              SizedBox(
                width: Get.width,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: const Color.fromRGBO(0, 149, 235, 1)),
                    onPressed: () {
                      controller.pageController.nextPage(
                          duration: 300.milliseconds, curve: Curves.ease);
                    },
                    child: const Text("Start Tutorial")),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class IntroSecond extends StatelessWidget {
  const IntroSecond({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 80,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                child: Text(
                  "Align your identity verification document with the specified position\n.",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Image.asset(
                "assets/images/drive_license_random.gif",
              ),
              const SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: Get.width,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(0, 149, 235, 1)),
                      onPressed: () {
                        controller.pageController.nextPage(
                            duration: 300.milliseconds, curve: Curves.ease);
                      },
                      child: const Text("Start Tutorial")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
