import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pkg/flutter_pkg.dart';

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var result; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                var params = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const DocumentVerification()));

                /// DATA [params] contains images in base64 Encoded Form
                /// in map key forms
                /// front contains document Front Image
                /// back  contains document back image
                /// tilted contains document tilted image
                /// selfie contains selfie image as file path e.g //abc.jpg different from other forms
                /// verification key contains boolean verifiaction check code
                result = params;
                setState(() {});
              },
              child: const Text("Start Verification")),
          if (result != null)
            Expanded(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.memory(base64Decode(result['front'])),
                  Image.memory(base64Decode(result['back'])),
                  Image.memory(base64Decode(result['tilted'])),
                  Image.file(File(result['selfie'])),
                ],
              ),
            ))
        ],
      )),
    );
  }
}
