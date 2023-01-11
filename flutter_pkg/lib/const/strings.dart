class AppStrings {
  static const FRONT = "FRONT";
  static const BACK = "BACK";
  static const TILTED = "TILTED";
  static const SELFIE = "SELFIE";
  static const LIVENESS = "LIVENESS";

  static const String DOCUMENT_VERIFICATION = "DOCUMENT VERIFICATION SDK";

  static const String BEGIN_PROCESS = "Begin Process";

  static const String RETAKE = "Retake";
  static const String NEXT = "Next";
}

class AppImages {
  static const DOCUMENT_FAIL = "";
  static const DIAGONAL_FAIL = "";
  static const SELFIE_FAIL = "";
}                

class TModels {
  static const FRONT_LABEL = "";
  static const BACK_LABEL = "assets/back/labels.txt";
  static const TILTED_LABEL = "assets/tilted/labels.txt";
  static const SELFIE_LABEL = "assets/face_final/labels.txt";
  static const LIVELINESS_LABEL = "assets/eye3/labels.txt";

  static const FRONT_MODEL = "assets/front_new/model_unquant.tflite";
  static const BACK_MODEL = "assets/back_rc/model_unquant.tflite";
  static const TILTED_MODEL = "assets/tilted/model_unquant.tflite";
  static const SELFIE_MODEL = "assets/face_final/model_unquant.tflite";
  static const LIVELINESS_MODEL = "assets/eye3/model_unquant.tflite";
}
