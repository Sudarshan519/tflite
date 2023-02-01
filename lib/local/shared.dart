import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences sharedPreferences;

// get app current state
  set currentState(int i) => sharedPreferences.setInt('currentState', i);
  int get currentState => sharedPreferences.getInt('currentState') ?? 0;

// front image
  set frontImage(String frontImage) =>
      sharedPreferences.setString('frontImage', frontImage);
  String get frontImage => sharedPreferences.getString('frontImage') ?? '';

// tilted image
  set tiltedImage(String tiltedImage) =>
      sharedPreferences.setString('tilted', tiltedImage);
  String get tiltedImage => sharedPreferences.getString('tilted') ?? '';

  // back image
  set backImage(String backImage) =>
      sharedPreferences.setString('backImage', backImage);
  String get backImage => sharedPreferences.getString('backImage') ?? '';

  // selfie image
  set selfieImage(String selfieImage) =>
      sharedPreferences.setString('selfieImage', selfieImage);
  String get backImage => sharedPreferences.getString('backImage') ?? '';

  // init preferences
  init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }
}
